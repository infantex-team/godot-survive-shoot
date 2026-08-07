class_name Magnet
extends Area2D

const BASE_VISUAL_RADIUS := 35.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual_polygon: Polygon2D = $Polygon2D

var _radius: float = 35.0
var _player: Player = null

func configure(radius: float, player: Player) -> void:
	_radius = radius
	_player = player
	if collision_shape and collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = _radius
	if visual_polygon:
		var visual_scale := _radius / BASE_VISUAL_RADIUS
		visual_polygon.scale = Vector2.ONE * visual_scale

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D) -> void:
	if area is XPPickup and is_instance_valid(area) and not area.is_collecting:
		area.set_target(_player)
