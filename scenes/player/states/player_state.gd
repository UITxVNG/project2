class_name PlayerState
extends FSMState

#Control moving and changing state to run
#Return true if moving
func control_moving() -> bool:
	var dir: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var is_moving: bool = abs(dir) > 0.1
	if is_moving:
		dir = sign(dir)
		obj.change_direction(dir)
		obj.velocity.x = obj.movement_speed * dir
		if obj.is_on_floor():
			change_state(fsm.states.run)
		return true
	else:
		obj.velocity.x = 0
	return false

#Control jumping
#Return true if jumping
func control_jump() -> bool:
	#If jump is pressed change to jump state and return true
	if Input.is_action_just_pressed("jump"):
		obj.jump()
		change_state(fsm.states.jump)
		return true
	return false

func take_damage(damage) -> void:
	#Player take damage
	obj.take_damage(damage)
	
	#Player die if health is 0 and change to dead state
	if obj.health <= 0:
		change_state(fsm.states.death)
	#Player hurt if health is not 0 and change to hurt state
	else:
		# You can implement hurt state here if needed
		pass
