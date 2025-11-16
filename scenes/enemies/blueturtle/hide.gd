extends EnemyState

var hide_timer: SceneTreeTimer

func _enter():
	super._enter()
	obj.hiding = true
	obj.velocity = Vector2.ZERO

	if obj.animated_sprite.animation != "hide":
		obj.change_animation("hide")
		obj.get_node("HitArea2D/CollisionShape2D").disabled = false
		obj.get_node("Direction/HurtArea2D/CollisionShape2D").disabled = false



	hide_timer = get_tree().create_timer(obj.hide_duration)
	hide_timer.timeout.connect(_on_hide_done)

	# tắt detect khi ẩn
	obj.disable_check_player_in_sight()

func _update(_delta):
	obj.velocity.x = 0

func _exit():
	super._exit()
	obj.hiding = false
	obj.enable_check_player_in_sight()

func _on_hide_done():
	if fsm.current_state == self:
		change_state(fsm.states.run)
