class_name Enemy
extends CharacterBody2D

signal enemy_died(score_value: int)

@export var speed: float = 80.0
@export var max_hp: int = 3
@export var damage: int = 1
@export var attack_cooldown: float = 1.0
@export var score_value: int = 10

@onready var hit_box: Area2D = $HitBox
@onready var attack_timer: Timer = $AttackTimer
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: Node2D = $HealthBar

var current_hp: int
var target_player: Player = null
var _player_in_hitbox: bool = false

func _ready() -> void:
	current_hp = max_hp
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	
	hit_box.body_entered.connect(_on_hitbox_body_entered)
	hit_box.body_exited.connect(_on_hitbox_body_exited)
	
	if anim_player.has_animation("walk"):
		anim_player.play("walk")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target_player):
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0] as Player
			
	if is_instance_valid(target_player) and not target_player.is_dead:
		var dir = (target_player.global_position - global_position).normalized()
		velocity = dir * speed
		look_at(target_player.global_position)
		move_and_slide()
	else:
		velocity = Vector2.ZERO

	if _player_in_hitbox and attack_timer.is_stopped():
		_deal_damage_to_player()

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

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_in_hitbox = true
		if attack_timer.is_stopped():
			_deal_damage_to_player()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body is Player:
		_player_in_hitbox = false

func _deal_damage_to_player() -> void:
	if is_instance_valid(target_player) and not target_player.is_dead:
		target_player.take_damage(damage)
		attack_timer.start()
