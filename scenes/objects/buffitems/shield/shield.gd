extends Area2D

@export var duration: float = 10.0  # 10 giây

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Player:
		body.apply_shield_buff(duration)
		queue_free()  # biến mất sau khi nhặt
