extends EnemyState

func _enter() -> void:
	obj.change_animation("run")
	obj.get_node("Direction/HurtArea2D/CollisionShape2D").disabled = false


func _update(delta):
	obj.velocity.x = obj.direction * obj.movement_speed

	if _should_turn_around() and obj.can_turn:
		obj.turn_around()
		obj.can_turn = false 

	if not _should_turn_around():
		obj.can_turn = true

	if obj.found_player:
		if obj.found_player.global_position.x > obj.global_position.x:
			obj.turn_right()
		else:
			obj.turn_left()
		change_state(fsm.states.hide)

func _should_turn_around() -> bool:
	if obj.hiding:
		return false 
	if obj.is_touch_wall():
		return true
	if obj.is_on_floor() and obj.is_can_fall():
		return true
	return false
