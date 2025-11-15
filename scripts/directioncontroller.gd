class_name DirectionController

signal _on_changed_direction

enum Direction {
	LEFT = -1, RIGHT = 1
}

var _direction_node: Node2D = null
var _direction: int = Direction.RIGHT
var _next_direction: int = -_direction

func _init(direction_node: Node2D) -> void:
	_direction_node = direction_node
	
func _update(_delta: float) -> void:
	_check_changed_direction()

func turn_around() -> void:
	change_direction(-_direction)

func change_direction(new_direction: int) -> void:
	_next_direction = new_direction
	
func get_direction() -> int:
	return _direction

func _check_changed_direction() -> void:
	if _next_direction != _direction:
		_direction = _next_direction
		_on_changed_direction.emit()
		_direction_node.scale.x = _direction
