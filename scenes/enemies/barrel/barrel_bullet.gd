extends RigidBody2D

func _ready() -> void:
	gravity_scale = 0
	contact_monitor = true
	max_contacts_reported = 4
	
	$CollisionShape2D.disabled = true
	await get_tree().create_timer(0.1).timeout
	$CollisionShape2D.disabled = false
	
func _on_hit_area_2d_hitted(_area: Variant) -> void:
	queue_free()
	
func _on_body_entered(_body: Node) -> void:
	queue_free()
