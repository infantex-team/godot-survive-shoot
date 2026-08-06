class_name XPLevelConfig
extends Resource

@export var xp_requirements: Array[int] = [5, 10, 20, 35, 55, 80, 110, 145, 185, 230]

func get_required_xp(level: int) -> int:
	var requirement_index := level - 1
	if requirement_index < 0 or requirement_index >= xp_requirements.size():
		return 0
	return maxi(0, xp_requirements[requirement_index])
