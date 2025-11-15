extends EnemyState

func _enter() -> void:
	obj.change_animation("idle")

func _update(delta):
	if obj.found_player:
		if obj.found_player.global_position.x > obj.global_position.x and obj.is_left():
			obj.turn_around()
		elif obj.found_player.global_position.x < obj.global_position.x and obj.is_right():
			obj.turn_around()
		change_state(fsm.states.attack)
