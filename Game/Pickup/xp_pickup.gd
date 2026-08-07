class_name XPPickup
extends Area2D

@export var value: int =1
@export var spread_duration: float = 0.28
@export var collectible_delay: float = 0.18
@export var spread_speed: float = 110.0
@export var magnet_speed: float = 260.0
@export var collection_effect_duration: float = 1
@export var is_collecting: bool = false

var _player: Player = null
var _spread_velocity: Vector2 = Vector2.ZERO
var _age: float = 0.0
var _collection_remaining: float = 0.0
var _reward_claimed: bool = false

func configure(amount: int, initial_velocity: Vector2) -> void:
	value = maxi(0,amount)
	_spread_velocity = initial_velocity
	_player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_player = null
	add_to_group("xp_pickups")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if value <= 0:
		queue_free()
		return
	
	if is_collecting:
		_update_collection_effect(delta)
		return
		
	_age += delta
	if _age <= spread_duration:
		global_position += _spread_velocity * delta
		_spread_velocity = _spread_velocity.move_toward(Vector2.ZERO, spread_speed * delta / maxf(0.001, spread_duration))
		return
	
	if _age < spread_duration + collectible_delay:
		return
	
	if not is_instance_valid(_player) or _player.is_dead:
		return

func set_target(player: Player) -> void:
	if not is_instance_valid(player) or player.is_dead:
		return
	_player = player
	_begin_collection()

func _begin_collection() -> void:
	if is_collecting :
		return
	is_collecting = true
	_collection_remaining = collection_effect_duration
	visible = true
	
func _update_collection_effect(detal: float) -> void:
	_collection_remaining -= detal
	if is_instance_valid(_player):
		global_position = global_position.move_toward(_player.global_position, magnet_speed * 1.5 * detal)
		
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
