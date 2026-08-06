class_name Player
extends CharacterBody2D

signal health_changed(current_hp: int, max_hp: int)
signal ammo_changed(current_ammo: int, max_ammo: int)
signal coins_changed(coins: int)
signal xp_changed(current_xp: int, required_xp: int, level: int)
signal level_changed(level: int)
signal died

@export var speed: float = 150.0
@export var max_hp: int = 5
@export var max_ammo: int = 30
@export var reload_time: float = 2.0
@export var shoot_cooldown: float = 0.2
@export var xp_magnet_radius: float = 90.0
@export var xp_level_config: XPLevelConfig = preload("res://Game/Player/default_xp_level_config.tres")

@onready var shoot_point: Marker2D = $ShootPoint
@onready var shoot_timer: Timer = $ShootTimer
@onready var reload_timer: Timer = $ReloadTimer
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var current_hp: int
var current_ammo: int
var coins: int = 0
var level: int = 1
var current_xp: int = 0
var is_reloading: bool = false
var is_dead: bool = false

var bullet_scene: PackedScene = preload("res://Game/Bullet/bullet.tscn")

func _ready() -> void:
	current_hp = max_hp
	current_ammo = max_ammo
	shoot_timer.wait_time = shoot_cooldown
	shoot_timer.one_shot = true
	reload_timer.wait_time = reload_time
	reload_timer.one_shot = true
	reload_timer.timeout.connect(_on_reload_finished)
	
	health_changed.emit(current_hp, max_hp)
	ammo_changed.emit(current_ammo, max_ammo)
	coins_changed.emit(coins)
	xp_changed.emit(current_xp, get_required_xp_for_next_level(), level)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	# Movement input
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir == Vector2.ZERO:
		# Fallback for standard UI keys if custom actions aren't fired
		dir.x = Input.get_axis("ui_left", "ui_right")
		dir.y = Input.get_axis("ui_up", "ui_down")
		dir = dir.normalized()
		
	velocity = dir * speed
	move_and_slide()
	
	# Rotation facing mouse
	look_at(get_global_mouse_position())
	
	# Animation state
	if dir != Vector2.ZERO:
		if anim_player.has_animation("walk") and anim_player.current_animation != "walk":
			anim_player.play("walk")
	else:
		if anim_player.has_animation("idle") and anim_player.current_animation != "idle":
			anim_player.play("idle")
			
	# Shooting
	if (Input.is_action_pressed("shoot") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and shoot_timer.is_stopped():
		shoot()

func shoot() -> void:
	if is_dead or is_reloading:
		return
		
	if current_ammo <= 0:
		start_reload()
		return
		
	current_ammo -= 1
	ammo_changed.emit(current_ammo, max_ammo)
	shoot_timer.start()
	
	var bullet := bullet_scene.instantiate() as Bullet
	get_parent().add_child(bullet)
	bullet.global_position = shoot_point.global_position
	bullet.direction = Vector2.RIGHT.rotated(rotation)
	bullet.rotation = rotation
	
	if current_ammo <= 0:
		start_reload()

func start_reload() -> void:
	if is_reloading or current_ammo == max_ammo:
		return
	is_reloading = true
	reload_timer.start()

func _on_reload_finished() -> void:
	is_reloading = false
	current_ammo = max_ammo
	ammo_changed.emit(current_ammo, max_ammo)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_hp -= amount
	if current_hp < 0:
		current_hp = 0
	health_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0:
		die()

func add_coin(amount: int = 1) -> void:
	coins += amount
	coins_changed.emit(coins)

func add_xp(amount: int) -> void:
	if amount <= 0 or is_dead:
		return
	
	current_xp += amount
	var leveled := false
	var required := get_required_xp_for_next_level()
	while required > 0 and current_xp >= required:
		current_xp -= required
		level += 1
		leveled = true
		required = get_required_xp_for_next_level()
	
	if leveled:
		level_changed.emit(level)
	xp_changed.emit(current_xp, required, level)

func get_required_xp_for_next_level() -> int:
	if not xp_level_config:
		return 0
	return xp_level_config.get_required_xp(level)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit()
