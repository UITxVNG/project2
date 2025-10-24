extends RigidBody2D

func _ready() -> void:
	$AnimatedSprite2D.play()
	$HitArea2D.hitted.connect(Callable(self, "_on_hit_area_2d_hitted"))

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	queue_free()
