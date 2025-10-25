extends "res://scenes/enemies/states/run.gd"
func _update(_delta):
	super._update(_delta)
	if obj.found_player:
		if obj.found_player.global_position.x > obj.global_position.x:
			obj.turn_right()
		else:
			obj.turn_left()
		change_state(fsm.states.attack)
