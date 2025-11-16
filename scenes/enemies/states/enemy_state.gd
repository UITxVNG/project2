extends FSMState
class_name EnemyState

signal enter
signal update(delta: float)
signal exit

func take_damage(damage: int = 1) -> void:
	obj.take_damage(damage)
	if obj.health <= 0:
		change_state(fsm.states.dead)
	else:
		change_state(fsm.states.hurt)
	return
	


func _enter() -> void:
	enter.emit()
	pass

func _exit() -> void:
	exit.emit()
	pass

func _update( _delta ):
	update.emit(_delta)
	pass
