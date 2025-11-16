extends AnimatableBody2D

@export var path_follow: PathFollow2D
@export var move_speed: float = 100.0

var last_pos: Vector2

func _ready():
	last_pos = global_position

func _physics_process(delta):
	if path_follow == null:
		return
	
	# Move path follow
	path_follow.progress += move_speed * delta
	
	# Calculate velocity BEFORE moving
	var target_pos = path_follow.global_position
	var velocity = (target_pos - last_pos) / delta
	
	# Move platform using sync_to_physics for proper collision
	global_position = target_pos
	
	# Update constant velocity for proper platform movement
	constant_linear_velocity = velocity
	
	# Store position for next frame
	last_pos = global_position
