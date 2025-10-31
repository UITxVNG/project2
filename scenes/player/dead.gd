extends PlayerState


func _enter():
	#change animation to dead
	obj.change_animation("dead")
	obj.velocity.x = 0
	timer = 2


func _update(delta: float):
	if update_timer(delta):
		obj.get_tree().reload_current_scene()
