extends PlayerState

func _enter() -> void:
	#Change animation to fall
	obj.change_animation("fall")
	pass

func _update(_delta: float) -> void:
	#Control moving
	if control_attack():
		return
	var is_moving: bool = control_moving()
	#If on floor change to idle if not moving and not jumping
	# Nếu có buff và chạm tường → wall cling
	if obj.decorator_manager and obj.decorator_manager.can_wall_cling():
		if obj.is_on_wall() and not obj.is_on_floor():
			change_state(fsm.states.wallcling)
			return
	if obj.is_on_floor() and not is_moving:
		change_state(fsm.states.idle)
	pass
