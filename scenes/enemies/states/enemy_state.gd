extends FSMState
class_name EnemyState

func take_damage(damage: int = 1) -> void:
	obj.take_damage(damage)
	if obj.health <= 0:
		change_state(fsm.states.dead)
	else:
		change_state(fsm.states.hurt)
	return
	
