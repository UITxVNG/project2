extends EnemyState

func _enter() -> void:
	obj.change_animation("dead")
	timer = 1.0
	obj.velocity.x = 0
	obj.set_physics_process(true)
	# Emit signal khi enemy chết
	obj.enemy_defeated.emit()

func _update(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		obj.queue_free()

func take_damage(damage: int = 1) -> void:
	if obj.health <= 0:
		return
	
	obj.take_damage(damage)
	
	if obj.health <= 0:
		change_state(fsm.states.dead)
	else:
		change_state(fsm.states.hurt)
