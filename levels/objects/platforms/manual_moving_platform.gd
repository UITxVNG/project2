extends AnimatableBody2D

@export var move_speed: float = 100.0
@export var move_distance: float = 200.0

var start_position: Vector2
var direction: int = 1

func _ready():
	start_position = global_position

func _physics_process(delta):
	# Check if reached the limit
	if global_position.y >= start_position.y + move_distance:
		direction = -1
	elif global_position.y <= start_position.y - move_distance:
		direction = 1
	
	# Set velocity and move
	var velocity = Vector2(0, move_speed * direction)
	move_and_collide(velocity * delta)
