extends PlayerState

func _enter() -> void:
	obj.change_animation("run")


func _update(delta: float):

	# Jump trước
	if control_jump():
		return

	# Attack
	if control_attack():
		return

	# Walk Smoke (hiệu ứng chạy)
	if obj.is_on_floor() and abs(obj.velocity.x) > 5:
		if obj.walk_smoke_timer <= 0:
			obj.play_walk_smoke()
			obj.walk_smoke_timer = 0.08    # độ dày khói (0.05–0.12 tuỳ bạn)

	# Control moving
	if not control_moving():
		change_state(fsm.states.idle)

	# Fall
	if not obj.is_on_floor():
		change_state(fsm.states.fall)
