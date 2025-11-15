extends EnemyState

func _enter():
	obj.change_animation("skill1")

	var left_bomb = obj.bullet_factory.spawn_bomb()
	left_bomb.direction = -1
	left_bomb.global_position = obj.global_position

	var right_bomb = obj.bullet_factory.spawn_bomb()
	right_bomb.direction = 1
	right_bomb.global_position = obj.global_position

	# sau 1.5 giây chuyển sang skill 2
	await get_tree().create_timer(1.5).timeout
	change_state(fsm.states.skill2)
