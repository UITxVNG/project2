class_name PatrolController

var _movement_range: float = 0
var _start_position: float = 0

func _init(movement_range: float) -> void:
	_movement_range = movement_range

func track_patrol(current_position: float, current_direction: int) -> bool:
	return (current_position - _start_position) * current_direction >= _movement_range

func set_start_position(position: float) -> void:
	_start_position = position

func set_movement_range(movement_range) -> void:
	_movement_range = movement_range
