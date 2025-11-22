extends "res://scenes/enemies/crab/hurt.gd"

func _update( delta: float):
	if update_timer(delta):
		change_state(fsm.states.idle)
