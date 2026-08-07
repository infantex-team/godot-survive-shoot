class_name HUD
extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var ammo_label: Label = %AmmoLabel
@onready var coin_label: Label = %CoinLabel
@onready var score_label: Label = %ScoreLabel
@onready var enemy_label: Label = %EnemyLabel
@onready var level_label: Label = %LevelLabel
@onready var xp_bar: ProgressBar = %XPBar
@onready var xp_label: Label = %XPLabel

func update_health(current: int, maximum: int) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current

func update_ammo(current: int, maximum: int) -> void:
	if ammo_label:
		ammo_label.text = "AMMO: %d/%d" % [current, maximum]

func update_level(level: int, exp: int, exp_to_next: int) -> void:
	if xp_bar:
		xp_bar.max_value = exp_to_next
		xp_bar.value = exp
	if level_label:
		level_label.text = "LEVEL: %d" % level
	if xp_label:
		xp_label.text = "EXP: %d/%d" % [exp, exp_to_next]

func update_coins(amount: int) -> void:
	if coin_label:
		coin_label.text = "COINS: %d" % amount

func update_score(score: int) -> void:
	if score_label:
		score_label.text = "SCORE: %d" % score

func update_enemy_count(count: int, maximum: int) -> void:
	if enemy_label:
		enemy_label.text = "ENEMIES: %d/%d" % [count, maximum]

func update_xp(current: int, required: int, level: int) -> void:
	if level_label:
		level_label.text = "LVL: %d" % level
	if xp_bar:
		xp_bar.max_value = max(1, required)
		xp_bar.value = current if required > 0 else xp_bar.max_value
	if xp_label:
		xp_label.text = "%d/%d" % [current, required] if required > 0 else "MAX"
