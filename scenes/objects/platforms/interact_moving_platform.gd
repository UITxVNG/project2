extends AnimatableBody2D

@export var speed: float = 200.0
@export var target_offset: Vector2 = Vector2(400, 0) # Khoảng cách đầu bên kia
var start_position: Vector2
var target_position: Vector2
var moving_to_target: bool = false

var player_on_platform: bool = false

func _ready() -> void:
	start_position = global_position
	target_position = start_position + target_offset

	$InteractiveArea2D.body_entered.connect(_on_body_entered)
	$InteractiveArea2D.body_exited.connect(_on_body_exited)

	set_process(true) # Luôn process để check input

func _process(delta: float) -> void:
	# Check input trực tiếp trong _process
	if player_on_platform and Input.is_action_just_pressed("interact") and not moving_to_target:
		print("Interact pressed")
		moving_to_target = true
		var temp = start_position
		start_position = target_position
		target_position = temp

	# Di chuyển platform
	if moving_to_target:
		var direction = (target_position - global_position).normalized()
		var step = speed * delta
		if global_position.distance_to(target_position) <= step:
			global_position = target_position
			moving_to_target = false
		else:
			global_position += direction * step

func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_on_platform = true
		print("Player entered platform:", body.name)

func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_on_platform = false
		print("Player exited platform:", body.name)
