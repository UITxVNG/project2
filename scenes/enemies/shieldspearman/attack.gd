extends EnemyState

func _enter() -> void:
	obj.change_animation("attack")
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = false

func _exit() -> void:
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = true

func _update(delta):
	if obj.found_player:
		if obj.found_player.global_position.x > obj.global_position.x and obj.is_left():
			obj.turn_around()
		elif obj.found_player.global_position.x < obj.global_position.x and obj.is_right():
			obj.turn_around()
	else:
		change_state(fsm.states.idle)
