extends AnimatableBody2D

@export var path_follow: PathFollow2D
@export var move_speed: float = 100.0

var velocity: Vector2 = Vector2.ZERO

func _ready():
	sync_to_physics = true

func _physics_process(delta):
	if path_follow == null or move_speed == 0:
		constant_linear_velocity = Vector2.ZERO
		return
	
	# Store old position
	var old_position = path_follow.global_position
	
	# Move path follow
	path_follow.progress += move_speed * delta
	
	# Calculate new position and velocity
	var new_position = path_follow.global_position
	velocity = (new_position - old_position) / delta
	
	# Update platform velocity BEFORE moving
	constant_linear_velocity = velocity
