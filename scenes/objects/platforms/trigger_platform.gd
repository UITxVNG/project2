extends Path2D

@export var move_speed: float = 100.0
@export var stop_at_end: bool = true  # Dừng lại ở cuối thay vì quay lại

var player_nearby: bool = false
var is_moving: bool = false
var f_was_pressed: bool = false

@onready var path_follow = $PathFollow2D
@onready var animatable_body = $PathFollow2D/AnimatableBody2D
@onready var interact_area = $PathFollow2D/AnimatableBody2D/InteractArea

func _ready():
	# Connect interact area signals
	if interact_area:
		# Use explicit connect with Callable for Godot 4
		interact_area.connect("body_entered", Callable(self, "_on_player_entered"))
		interact_area.connect("body_exited", Callable(self, "_on_player_exited"))
	
	# Set initial speed to 0
	if animatable_body:
		animatable_body.move_speed = 0

	# Ensure the PathFollow does not loop so we can stop at the end
	if path_follow:
		# disable looping so progress_ratio will reach 1.0 and stay
		path_follow.loop = false

func _process(_delta):
	# Check for F key input when player is nearby
	# Use an input action named "interact" (map it to the F key in Project Settings -> Input Map)
	var f_pressed = Input.is_action_just_pressed("interact")
	
	if player_nearby and f_pressed and not f_was_pressed:
		print("F pressed! Toggling movement")
		toggle_movement()
	
	f_was_pressed = f_pressed
	
	# Stop at end if enabled
	if is_moving and stop_at_end:
		if path_follow and path_follow.progress_ratio >= 0.999:
			# clamp to exact end and stop
			is_moving = false
			animatable_body.move_speed = 0
		

func toggle_movement():
	# If the platform previously reached the end and stopped, reset it to start
	if not is_moving and path_follow and stop_at_end and path_follow.progress_ratio >= 0.999:
		# move back to start so interaction can reuse platform
		if path_follow.curve:
			path_follow.progress = 0
		else:
			path_follow.progress = 0

	is_moving = !is_moving
	var speed = move_speed if is_moving else 0.0
	print("Platform moving: ", is_moving, " speed: ", speed)
	if animatable_body:
		animatable_body.move_speed = speed

func _on_player_entered(body):
	if body.name == "Player":
		player_nearby = true

func _on_player_exited(body):
	if body.name == "Player":
		player_nearby = false
