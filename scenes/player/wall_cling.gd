extends PlayerState

func _enter() -> void:
	obj.change_animation("fall")
	obj.velocity.y = 50      # trượt xuống từ từ
	obj.velocity.x = 0       # ép vào tường 1 lần duy nhất


func _update(delta: float) -> void:

	# Nếu nhảy khỏi tường
	if Input.is_action_just_pressed("jump"):
		obj.wall_cling_lockout = 1          # tránh bám tường lại
		obj.velocity.y = -obj.get_jump_speed()
		obj.velocity.x = -obj.direction * obj.get_movement_speed() * 1.2
		obj.play_jump_smoke() 
		change_state(fsm.states.jump)
		return

	# Nếu rời tường
	if not obj.is_on_wall():
		change_state(fsm.states.fall)
		return

	# Trượt xuống chậm
	obj.velocity.y = min(obj.velocity.y + obj.gravity * 0.1 * delta, 80)
