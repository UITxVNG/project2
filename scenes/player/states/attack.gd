extends PlayerState

@export var attack_duration: float = 0.5
var attack_timer: float = 0.0

func _enter() -> void:
	# If in air, switch to jump attack
	if not obj.is_on_floor():
		change_state(fsm.states["jump_attack"])
		return

	obj.change_animation("attack")
		#Enable collision shape of hit area

	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = false
	attack_timer = attack_duration
	
func _exit() -> void:

	#Disable collision shape of hit area

	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = true
func _update(_delta: float) -> void:
	attack_timer -= _delta

	# Optional: allow light horizontal movement
	control_moving()

	if attack_timer <= 0.0:
		if abs(obj.velocity.x) > 0:
			change_state(fsm.states["move"])
		else:
			change_state(fsm.states["idle"])
