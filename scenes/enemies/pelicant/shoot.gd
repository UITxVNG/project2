extends "res://scenes/enemies/barrel/shoot.gd"

	
func _update(_delta: float):
	if attack_timer > 0:
		attack_timer -= _delta
		if attack_timer <= 0:
			obj.attack()
	if update_timer(_delta):
		change_state(fsm.previous_state)
