extends EnemyState

func _enter():
	obj.change_animation("hurt")
	timer = 0.5
	obj.velocity.y = -100
	obj.velocity.x = -100*sign(obj.velocity.x)


func _update( delta: float):
	if update_timer(delta):
		change_state(fsm.states.idle)
