extends PlayerState

## Idle state for player character

func _enter() -> void:
	obj.change_animation("idle")

func _update(_delta: float) -> void:
	# --- Handle input ---
	if Input.is_action_just_pressed("attack") and obj.can_attack():
		if obj.is_on_floor():
			change_state(fsm.states["attack"])        # ground attack
		else:
			change_state(fsm.states["jump_attack"])   # air attack
		return  # Important: stop further idle logic this frame

	# --- Movement ---
	control_jump()
	control_moving()

	# --- Falling check ---
	if not obj.is_on_floor():
		change_state(fsm.states["fall"])
