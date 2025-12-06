extends EnemyState

func _enter():
	print("ENTER BROKEN")
	obj.change_animation("broken")
	obj.emit_signal("rock_broken")

	# Chờ animation xong
	await obj.animated_sprite.animation_finished


	obj.queue_free()
