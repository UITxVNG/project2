extends PlayerState

func _enter() -> void:
	obj.change_animation("attack")
	timer = 0.35
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = false

func _exit() -> void:
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = true

func _update(delta: float) -> void:
	# ONLY let attack finish, no other input allowed
	if update_timer(delta):
		change_state(fsm.previous_state)
		return

	# gravity / falling allowed
	if not obj.is_on_floor():
		obj.change_animation("attack")  # optional
