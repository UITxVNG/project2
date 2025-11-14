extends EnemyState


func _enter() -> void:
	obj.change_animation("attack")
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = false
