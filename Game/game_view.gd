extends Node2D

@export var initial_spawn_interval: float = 3.0
@export var min_spawn_interval: float = 1.0
@export var spawn_decrease_rate: float = 0.05

@onready var player: Player = $Player
@onready var hud: HUD = $HUD
@onready var game_over_panel: GameOverPanel = $GameOverPanel
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var enemies_container: Node2D = $Enemies
@onready var bullets_container: Node2D = $Bullets

var enemy_scene: PackedScene = preload("res://Game/Enemy/enemy.tscn")

var score: int = 0
var current_spawn_interval: float

func _ready() -> void:
	current_spawn_interval = initial_spawn_interval
	enemy_spawn_timer.wait_time = current_spawn_interval
	enemy_spawn_timer.timeout.connect(_on_enemy_spawn_timer_timeout)
	enemy_spawn_timer.start()
	
	if player:
		player.health_changed.connect(_on_player_health_changed)
		player.ammo_changed.connect(_on_player_ammo_changed)
		player.coins_changed.connect(_on_player_coins_changed)
		player.died.connect(_on_player_died)
		
		hud.update_health(player.current_hp, player.max_hp)
		hud.update_ammo(player.current_ammo, player.max_ammo)
		hud.update_coins(player.coins)
		
	hud.update_score(score)
	game_over_panel.restart_requested.connect(_on_restart_requested)

func _on_enemy_spawn_timer_timeout() -> void:
	_spawn_enemy()
	# Gradually decrease spawn interval for ramping difficulty
	if current_spawn_interval > min_spawn_interval:
		current_spawn_interval = max(min_spawn_interval, current_spawn_interval - spawn_decrease_rate)
		enemy_spawn_timer.wait_time = current_spawn_interval

func _spawn_enemy() -> void:
	var enemy := enemy_scene.instantiate() as Enemy
	enemies_container.add_child(enemy)
	enemy.global_position = _get_random_spawn_position()
	enemy.configure_patrol_route(_build_patrol_route(enemy.global_position))
	enemy.enemy_died.connect(_on_enemy_died)

func _get_random_spawn_position() -> Vector2:
	var side = randi() % 4
	match side:
		0: # Top
			return Vector2(randf_range(30, 330), 30)
		1: # Bottom
			return Vector2(randf_range(30, 330), 610)
		2: # Left
			return Vector2(30, randf_range(30, 610))
		_: # Right
			return Vector2(330, randf_range(30, 610))

func _build_patrol_route(origin: Vector2) -> Array[Vector2]:
	var route: Array[Vector2] = []
	var patrol_radius := randf_range(45.0, 85.0)
	var start_angle := randf() * TAU
	for index in range(4):
		var offset := Vector2.RIGHT.rotated(start_angle + TAU * float(index) / 4.0) * patrol_radius
		route.append(_clamp_to_arena(origin + offset))
	return route

func _clamp_to_arena(point: Vector2) -> Vector2:
	return Vector2(
		clampf(point.x, 30.0, 330.0),
		clampf(point.y, 30.0, 610.0)
	)

func _on_enemy_died(points: int) -> void:
	score += points
	hud.update_score(score)

func _on_player_health_changed(current: int, maximum: int) -> void:
	hud.update_health(current, maximum)

func _on_player_ammo_changed(current: int, maximum: int) -> void:
	hud.update_ammo(current, maximum)

func _on_player_coins_changed(amount: int) -> void:
	hud.update_coins(amount)

func _on_player_died() -> void:
	enemy_spawn_timer.stop()
	game_over_panel.show_panel(score)

func _on_restart_requested() -> void:
	get_tree().reload_current_scene()
