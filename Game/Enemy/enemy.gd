class_name Enemy
extends CharacterBody2D

signal enemy_died(score_value: int)

enum AIState {
	PATROL,
	CHASE,
	INVESTIGATE,
	RETURN
}

const PLAYER_GROUP := "player"
const ENEMY_GROUP := "enemies"
const WALL_COLLISION_MASK := 8

@export_category("Combat")
@export var max_hp: int = 3
@export var damage: int = 1
@export var attack_cooldown: float = 1.0
@export var score_value: int = 10

@export_category("Movement")
@export var patrol_speed: float = 70.0
@export var chase_speed: float = 110.0
@export var investigate_speed: float = 85.0
@export var return_speed: float = 85.0
@export var acceleration: float = 700.0
@export var turn_speed: float = 12.0
@export var waypoint_reached_distance: float = 14.0
@export var path_update_interval: float = 0.25
@export var target_repath_distance: float = 16.0

@export_category("Patrol")
@export var patrol_waypoints: Array[Vector2] = []
@export var loop_patrol: bool = true
@export var ping_pong_patrol: bool = false
@export var wait_at_waypoint: float = 0.15

@export_category("Detection")
@export var vision_range: float = 220.0
@export_range(1.0, 360.0, 1.0, "degrees") var field_of_view_degrees: float = 95.0
@export var sight_memory_time: float = 0.65
@export var min_state_time: float = 0.2

@export_category("Investigation")
@export var search_duration: float = 3.0
@export var search_radius: float = 48.0
@export var search_retarget_interval: float = 0.7

@export_category("Avoidance")
@export var separation_radius: float = 30.0
@export var separation_strength: float = 95.0

@onready var hit_box: Area2D = $HitBox
@onready var attack_timer: Timer = $AttackTimer
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: Node2D = $HealthBar
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var current_hp: int
var target_player: Player = null

var state: int = AIState.PATROL
var last_known_player_position: Vector2

var _player_in_hitbox: bool = false
var _patrol_index: int = 0
var _saved_patrol_index: int = 0
var _patrol_direction: int = 1
var _patrol_wait_remaining: float = 0.0
var _search_remaining: float = 0.0
var _search_retarget_remaining: float = 0.0
var _is_searching_area: bool = false
var _state_time: float = 0.0
var _time_since_seen: float = INF
var _path_update_remaining: float = 0.0
var _current_move_target: Vector2
var _has_move_target: bool = false
var _last_facing_direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	current_hp = max_hp
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	_current_move_target = global_position
	last_known_player_position = global_position
	
	hit_box.body_entered.connect(_on_hitbox_body_entered)
	hit_box.body_exited.connect(_on_hitbox_body_exited)
	
	if navigation_agent:
		navigation_agent.path_desired_distance = waypoint_reached_distance
		navigation_agent.target_desired_distance = waypoint_reached_distance
		navigation_agent.radius = max(8.0, separation_radius * 0.35)
		navigation_agent.max_speed = chase_speed
		navigation_agent.avoidance_enabled = true
	
	_normalize_patrol_route()
	_acquire_player()
	
	if anim_player.has_animation("walk"):
		anim_player.play("walk")

func _physics_process(delta: float) -> void:
	_state_time += delta
	_path_update_remaining = maxf(0.0, _path_update_remaining - delta)
	_update_player_memory(delta)
	_update_state(delta)
	_move_for_state(delta)
	
	if _player_in_hitbox and attack_timer.is_stopped():
		_deal_damage_to_player()

func configure_patrol_route(points: Array[Vector2]) -> void:
	patrol_waypoints = points.duplicate()
	_normalize_patrol_route()
	state = AIState.PATROL
	_patrol_index = _get_nearest_patrol_index()
	_saved_patrol_index = _patrol_index
	_set_move_target(_get_current_patrol_point(), true)

func take_damage(amount: int) -> void:
	current_hp -= amount
	if health_bar and health_bar.has_method("update_health"):
		health_bar.update_health(current_hp, max_hp)
	
	if current_hp <= 0:
		die()

func die() -> void:
	enemy_died.emit(score_value)
	if is_instance_valid(target_player):
		target_player.add_coin(1)
	queue_free()

func _update_player_memory(delta: float) -> void:
	if not is_instance_valid(target_player) or target_player.is_dead:
		_acquire_player()
	
	if is_instance_valid(target_player) and not target_player.is_dead and _can_see_player(target_player):
		last_known_player_position = target_player.global_position
		_time_since_seen = 0.0
	else:
		_time_since_seen += delta

func _update_state(delta: float) -> void:
	match state:
		AIState.PATROL:
			if _can_change_state() and _has_recent_player_sight():
				_change_state(AIState.CHASE)
		AIState.CHASE:
			if _has_recent_player_sight():
				return
			if _can_change_state() and _time_since_seen >= sight_memory_time:
				_change_state(AIState.INVESTIGATE)
		AIState.INVESTIGATE:
			if _is_searching_area:
				_search_remaining -= delta
				_search_retarget_remaining -= delta
			if _can_change_state() and _has_recent_player_sight():
				_change_state(AIState.CHASE)
			elif _is_searching_area and _search_remaining <= 0.0 and _can_change_state():
				_change_state(AIState.RETURN)
		AIState.RETURN:
			if _can_change_state() and _has_recent_player_sight():
				_change_state(AIState.CHASE)
			elif _is_at_position(_get_current_patrol_point()):
				_change_state(AIState.PATROL)

func _move_for_state(delta: float) -> void:
	var desired_speed := patrol_speed
	match state:
		AIState.PATROL:
			desired_speed = patrol_speed
			_update_patrol_target(delta)
		AIState.CHASE:
			desired_speed = chase_speed
			_set_move_target(last_known_player_position)
		AIState.INVESTIGATE:
			desired_speed = investigate_speed
			_update_investigation_target()
		AIState.RETURN:
			desired_speed = return_speed
			_set_move_target(_get_current_patrol_point())
	
	var desired_velocity := _get_desired_velocity(desired_speed)
	desired_velocity += _get_separation_velocity()
	if desired_velocity.length() > desired_speed:
		desired_velocity = desired_velocity.normalized() * desired_speed
	
	velocity = velocity.move_toward(desired_velocity, acceleration * delta)
	move_and_slide()
	_update_facing(delta)
	_update_animation()

func _update_patrol_target(delta: float) -> void:
	if patrol_waypoints.is_empty():
		_set_move_target(global_position)
		return
	
	if _patrol_wait_remaining > 0.0:
		_patrol_wait_remaining -= delta
		_has_move_target = false
		return
	
	var patrol_point := _get_current_patrol_point()
	_set_move_target(patrol_point)
	if _is_at_position(patrol_point):
		_advance_patrol_index()
		_patrol_wait_remaining = wait_at_waypoint
		_set_move_target(_get_current_patrol_point(), true)

func _update_investigation_target() -> void:
	if not _is_searching_area:
		_set_move_target(last_known_player_position)
		if _is_at_position(last_known_player_position):
			_is_searching_area = true
			_search_remaining = search_duration
			_search_retarget_remaining = 0.0
		return
	
	if not _has_move_target or _is_at_position(_current_move_target) or _search_retarget_remaining <= 0.0:
		var offset := Vector2.RIGHT.rotated(randf() * TAU) * randf_range(0.0, search_radius)
		_set_move_target(last_known_player_position + offset, true)
		_search_retarget_remaining = search_retarget_interval

func _get_desired_velocity(desired_speed: float) -> Vector2:
	if not _has_move_target:
		return Vector2.ZERO
	
	var next_position := _current_move_target
	if navigation_agent and not navigation_agent.is_navigation_finished():
		next_position = navigation_agent.get_next_path_position()
	
	var to_next := next_position - global_position
	if to_next.length() <= waypoint_reached_distance * 0.5:
		to_next = _current_move_target - global_position
	if to_next.length() <= 1.0:
		return Vector2.ZERO
	return to_next.normalized() * desired_speed

func _set_move_target(target: Vector2, force: bool = false) -> void:
	if not force and _has_move_target:
		if _current_move_target.distance_to(target) < target_repath_distance:
			return
		if _path_update_remaining > 0.0:
			return
	
	_has_move_target = true
	_current_move_target = target
	_path_update_remaining = path_update_interval
	if navigation_agent:
		navigation_agent.target_position = target

func _change_state(next_state: int) -> void:
	if state == next_state:
		return
	var previous_state := state
	state = next_state
	_state_time = 0.0
	_patrol_wait_remaining = 0.0
	if previous_state == AIState.PATROL:
		_saved_patrol_index = _patrol_index
	
	match state:
		AIState.PATROL:
			_patrol_index = clampi(_saved_patrol_index, 0, patrol_waypoints.size() - 1)
			_set_move_target(_get_current_patrol_point(), true)
		AIState.CHASE:
			_set_move_target(last_known_player_position, true)
		AIState.INVESTIGATE:
			_search_remaining = search_duration
			_search_retarget_remaining = search_retarget_interval
			_is_searching_area = false
			_set_move_target(last_known_player_position, true)
		AIState.RETURN:
			_patrol_index = clampi(_saved_patrol_index, 0, patrol_waypoints.size() - 1)
			_set_move_target(_get_current_patrol_point(), true)

func _can_see_player(player: Player) -> bool:
	if not is_instance_valid(player) or player.is_dead:
		return false
	
	var to_player := player.global_position - global_position
	if to_player.length() > vision_range:
		return false
	
	var facing := _last_facing_direction
	if velocity.length() > 5.0:
		facing = velocity.normalized()
	
	var half_fov := deg_to_rad(field_of_view_degrees) * 0.5
	if absf(facing.angle_to(to_player.normalized())) > half_fov:
		return false
	
	var query := PhysicsRayQueryParameters2D.create(global_position, player.global_position, WALL_COLLISION_MASK)
	query.exclude = [self]
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	return hit.is_empty()

func _get_separation_velocity() -> Vector2:
	var separation := Vector2.ZERO
	for node in get_tree().get_nodes_in_group(ENEMY_GROUP):
		if node == self or not is_instance_valid(node) or not (node is Node2D):
			continue
		var other := node as Node2D
		var offset := global_position - other.global_position
		var distance := offset.length()
		if distance > 0.01 and distance < separation_radius:
			separation += offset.normalized() * (1.0 - distance / separation_radius)
	return separation * separation_strength

func _normalize_patrol_route() -> void:
	if patrol_waypoints.is_empty():
		patrol_waypoints = [
			global_position + Vector2(-48.0, 0.0),
			global_position + Vector2(48.0, 0.0)
		]
	_patrol_index = clampi(_patrol_index, 0, patrol_waypoints.size() - 1)
	_set_move_target(_get_current_patrol_point(), true)

func _advance_patrol_index() -> void:
	if patrol_waypoints.size() <= 1:
		return
	
	if ping_pong_patrol:
		if _patrol_index >= patrol_waypoints.size() - 1:
			_patrol_direction = -1
		elif _patrol_index <= 0:
			_patrol_direction = 1
		_patrol_index += _patrol_direction
	elif loop_patrol:
		_patrol_index = (_patrol_index + 1) % patrol_waypoints.size()
	else:
		_patrol_index = mini(_patrol_index + 1, patrol_waypoints.size() - 1)

func _get_current_patrol_point() -> Vector2:
	if patrol_waypoints.is_empty():
		return global_position
	return patrol_waypoints[_patrol_index]

func _get_nearest_patrol_index() -> int:
	if patrol_waypoints.is_empty():
		return 0
	
	var nearest_index := 0
	var nearest_distance := INF
	for index in range(patrol_waypoints.size()):
		var distance := global_position.distance_squared_to(patrol_waypoints[index])
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_index = index
	return nearest_index

func _is_at_position(point: Vector2) -> bool:
	return global_position.distance_to(point) <= waypoint_reached_distance

func _has_recent_player_sight() -> bool:
	return _time_since_seen <= sight_memory_time

func _can_change_state() -> bool:
	return _state_time >= min_state_time

func _acquire_player() -> void:
	target_player = null
	for node in get_tree().get_nodes_in_group(PLAYER_GROUP):
		if node is Player and is_instance_valid(node) and not node.is_dead:
			target_player = node
			return

func _update_facing(delta: float) -> void:
	if velocity.length() <= 5.0:
		return
	_last_facing_direction = velocity.normalized()
	var target_rotation := _last_facing_direction.angle()
	rotation = lerp_angle(rotation, target_rotation, clampf(turn_speed * delta, 0.0, 1.0))

func _update_animation() -> void:
	if velocity.length() > 2.0:
		if anim_player.has_animation("walk") and anim_player.current_animation != "walk":
			anim_player.play("walk")
	else:
		if anim_player.has_animation("idle") and anim_player.current_animation != "idle":
			anim_player.play("idle")

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_in_hitbox = true
		target_player = body
		if attack_timer.is_stopped():
			_deal_damage_to_player()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body is Player:
		_player_in_hitbox = false

func _deal_damage_to_player() -> void:
	if is_instance_valid(target_player) and not target_player.is_dead:
		target_player.take_damage(damage)
		attack_timer.start()
