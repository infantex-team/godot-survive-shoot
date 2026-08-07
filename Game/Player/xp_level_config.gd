extends Resource
class_name XPLevelConfig

@export var xp_requirements: Array[int] = [15, 25, 50, 100, 150, 200, 250, 300, 400, 500]

func get_required_xp(level: int) -> int:
	var requirement_index := level - 1
	if requirement_index < 0 or requirement_index >= xp_requirements.size():
		return	0
	return maxi(0,xp_requirements[requirement_index])
