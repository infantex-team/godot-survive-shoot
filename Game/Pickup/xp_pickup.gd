class_name XPPickup
extends Area2D

@export var value: int = 1
@export var spread_duration: float = 0.28
@export var collectible_delay: float = 0.18
@export var spread_speed: float = 110.0
@export var magnet_speed: float = 260.0
@export var collection_distance: float = 8.0
@export var collection_effect_duration: float = 0.08

var _player: Player = null
var _spread_velocity: Vector2 = Vector2.ZERO
var _age: float = 0.0
var _is_collecting: bool = false
var _collection_remaining: float = 0.0
var _reward_claimed: bool = false

func configure(amount: int, initial_velocity: Vector2, player: Player) -> void:
	value = maxi(0, amount)
	_spread_velocity = initial_velocity
	_player = player

func _ready() -> void:
	add_to_group("xp_pickups")

func _process(delta: float) -> void:
	if value <= 0:
		queue_free()
		return
	
	if _is_collecting:
		_update_collection_effect(delta)
		return
	
	_age += delta
	if _age <= spread_duration:
		global_position += _spread_velocity * delta
		_spread_velocity = _spread_velocity.move_toward(Vector2.ZERO, spread_speed * delta / maxf(0.001, spread_duration))
		return
	
	if _age < spread_duration + collectible_delay:
		return
	
	_acquire_player()
	if not is_instance_valid(_player) or _player.is_dead:
		return
	
	var distance := global_position.distance_to(_player.global_position)
	if distance > _player.xp_magnet_radius:
		return
	
	global_position = global_position.move_toward(_player.global_position, magnet_speed * delta)
	if distance <= collection_distance:
		_begin_collection()

func _acquire_player() -> void:
	if is_instance_valid(_player) and not _player.is_dead:
		return
	for node in get_tree().get_nodes_in_group("player"):
		if node is Player and is_instance_valid(node) and not node.is_dead:
			_player = node
			return

func _begin_collection() -> void:
	if _is_collecting:
		return
	_is_collecting = true
	_collection_remaining = collection_effect_duration
	visible = true
	set_process(true)

func _update_collection_effect(delta: float) -> void:
	_collection_remaining -= delta
	if is_instance_valid(_player):
		global_position = global_position.move_toward(_player.global_position, magnet_speed * 1.5 * delta)
	
	var progress := 1.0 - maxf(_collection_remaining, 0.0) / maxf(0.001, collection_effect_duration)
	scale = Vector2.ONE * lerpf(1.0, 1.8, progress)
	modulate.a = lerpf(1.0, 0.0, progress)
	
	if _collection_remaining <= 0.0:
		_claim_reward()

func _claim_reward() -> void:
	if _reward_claimed:
		return
	_reward_claimed = true
	if is_instance_valid(_player) and not _player.is_dead:
		_player.add_xp(value)
	queue_free()
