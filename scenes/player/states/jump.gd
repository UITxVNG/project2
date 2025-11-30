extends PlayerState

func _enter() -> void:
	#Change animation to jump
	obj.change_animation("jump")
	pass

func _update(_delta: float):
	#Control moving
	control_moving()
	if control_attack():
		return
	# Nếu có WALL CLING BUFF và đang chạm tường → vào wall cling
	if obj.decorator_manager and obj.decorator_manager.can_wall_cling():
		if obj.is_on_wall() and not obj.is_on_floor():
			change_state(fsm.states.wallcling)
			return
	#If velocity.y is greater than 0 change to fall
	if obj.velocity.y > 0:
		change_state(fsm.states.fall)
	pass
