extends EnemyState

@export var attack_delay: float = 0.3
var attack_timer: float = 0.0

func _enter():
	obj.change_animation("Shoot")
	attack_timer = attack_delay
	timer = 0.5
	
func _update(_delta: float):
	if attack_timer > 0:
		attack_timer -= _delta
		if attack_timer <= 0:
			obj.fire()
	if update_timer(_delta):
		change_state(fsm.previous_state)
