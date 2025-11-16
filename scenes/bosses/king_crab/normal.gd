extends EnemyState

func _enter() -> void:
	super._enter()
	timer = obj.idle_time

func _exit() -> void:
	super._exit()

func _update( _delta ):
	super._update(_delta)
	if update_timer(_delta):
		fsm.change_state(obj.get_current_skill());
