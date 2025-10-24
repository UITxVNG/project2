extends PlayerState

@export var attack_duration: float = 0.4
var attack_timer: float = 0.0

func _enter() -> void:
	obj.change_animation("jump_attack")
	attack_timer = attack_duration

func _update(delta: float) -> void:
	attack_timer -= delta

	# Allow limited horizontal movement
	control_moving()

	# Gravity
	obj.velocity.y += obj.gravity * delta
	obj.move_and_slide()

	if attack_timer <= 0.0:
		if not obj.is_on_floor():
			change_state(fsm.states["fall"])
		else:
			change_state(fsm.states["idle"])
