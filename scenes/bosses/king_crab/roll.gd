extends EnemyState

func _enter() -> void:
	super._enter()
	timer = obj.rolling_time

func _update(delta):
	super._update(delta)

	obj.velocity.x = obj.direction * obj._movement_speed
	obj.move_and_slide()

	if update_timer(delta) or obj.is_can_fall() or obj.is_touch_wall():
		fsm.change_state(fsm.states.stoproll)
