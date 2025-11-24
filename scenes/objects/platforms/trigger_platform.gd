extends Path2D

@export var move_speed: float = 100.0
@export var stop_at_end: bool = true  # Dừng lại ở cuối thay vì quay lại

var player_nearby: bool = false
var is_moving: bool = false

@onready var path_follow = $PathFollow2D
@onready var animatable_body = $PathFollow2D/AnimatableBody2D
@onready var interact_area = $PathFollow2D/AnimatableBody2D/InteractArea

func _ready():
	# Connect interact area signals
	if interact_area:
		interact_area.body_entered.connect(_on_player_entered)
		interact_area.body_exited.connect(_on_player_exited)
	
	# Set initial speed to 0
	if animatable_body:
		animatable_body.move_speed = 0

func _process(_delta):
	# Check for F key input when player is nearby
	if player_nearby and Input.is_action_just_pressed("interact"):
		toggle_movement()
	
	# Stop at end if enabled
	if is_moving and stop_at_end:
		if path_follow.progress_ratio >= 1.0:
			is_moving = false
			animatable_body.move_speed = 0

func toggle_movement():
	is_moving = !is_moving
	if not is_moving:
		animatable_body.move_speed = 0
	else:
		animatable_body.move_speed = move_speed

func _on_player_entered(body):
	if body.name == "Player":
		player_nearby = true

func _on_player_exited(body):
	if body.name == "Player":
		player_nearby = false
