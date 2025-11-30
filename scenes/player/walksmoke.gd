extends AnimatedSprite2D

func _ready():
	play("walk_smoke")
	animation_finished.connect(_on_finished)

func _on_finished():
	queue_free()  # Tự xóa sau khi animation xong
