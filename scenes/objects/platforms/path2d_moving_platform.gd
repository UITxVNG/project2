extends Path2D

@export var move_speed: float = 100.0:
	set(value):
		move_speed = value
		if has_node("PathFollow2D/AnimatableBody2D"):
			$PathFollow2D/AnimatableBody2D.move_speed = value

func _ready():
	# Set initial speed to AnimatableBody2D
	if has_node("PathFollow2D/AnimatableBody2D"):
		$PathFollow2D/AnimatableBody2D.move_speed = move_speed
