
extends PlayerState


func _enter() -> void:

	#Change animation to attack

	obj.change_animation("attack")

	timer = 0.5

	obj.velocity.x = 0

	#Enable collision shape of hit area

	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = false


func _exit() -> void:

	#Disable collision shape of hit area

	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = true


func _update(delta: float) -> void:

	#If attack is finished change to previous state

	if update_timer(delta):

		change_state(fsm.previous_state)
