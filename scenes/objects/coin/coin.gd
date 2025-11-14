extends Area2D

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	$AnimatedSprite2D.play("collected")
	$Coin.play()
	await $AnimatedSprite2D.animation_finished
	queue_free()
