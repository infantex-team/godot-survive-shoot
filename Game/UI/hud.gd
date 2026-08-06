class_name HUD
extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var ammo_label: Label = %AmmoLabel
@onready var coin_label: Label = %CoinLabel
@onready var score_label: Label = %ScoreLabel
@onready var enemy_label: Label = %EnemyLabel

func update_health(current: int, maximum: int) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current

func update_ammo(current: int, maximum: int) -> void:
	if ammo_label:
		ammo_label.text = "AMMO: %d/%d" % [current, maximum]

func update_coins(amount: int) -> void:
	if coin_label:
		coin_label.text = "COINS: %d" % amount

func update_score(score: int) -> void:
	if score_label:
		score_label.text = "SCORE: %d" % score

func update_enemy_count(count: int, maximum: int) -> void:
	if enemy_label:
		enemy_label.text = "ENEMIES: %d/%d" % [count, maximum]
