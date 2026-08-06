extends Node2D

var _current_hp: int = 3
var _max_hp: int = 3

func update_health(current: int, maximum: int) -> void:
	_current_hp = current
	_max_hp = maximum
	queue_redraw()

func _draw() -> void:
	if _current_hp >= _max_hp or _max_hp <= 0:
		return # Hide health bar when full
		
	var width: float = 24.0
	var height: float = 4.0
	var pos := Vector2(-width / 2.0, -18.0)
	
	# Background (red/grey)
	draw_rect(Rect2(pos, Vector2(width, height)), Color(0.2, 0.2, 0.2, 0.8))
	
	# Foreground (green)
	var fill_width = width * (float(_current_hp) / float(_max_hp))
	if fill_width > 0:
		draw_rect(Rect2(pos, Vector2(fill_width, height)), Color(0.85, 0.2, 0.2, 1.0))
