extends EnemyState

func _update( _delta ):
	super._update(_delta)
	if obj.is_attaching():
		fsm.change_state(fsm.states.recall)
	pass
