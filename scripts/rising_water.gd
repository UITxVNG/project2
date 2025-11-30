extends Area2D

## Rising water that kills the player on contact and continuously rises

@export var rise_speed: float = 20.0  # Tốc độ nước dâng (pixels/giây)
@export var start_delay: float = 2.0  # Thời gian delay trước khi bắt đầu dâng

var is_rising: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Delay trước khi bắt đầu dâng
	await get_tree().create_timer(start_delay).timeout
	is_rising = true

func _process(delta: float) -> void:
	if is_rising:
		# Dịch chuyển nước lên trên (giảm Y)
		position.y -= rise_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body is Player:
		var player = body as Player
		# Kill player instantly
		player.health = 0
		if player.fsm and player.fsm.states.has("dead"):
			player.fsm.change_state(player.fsm.states["dead"])
