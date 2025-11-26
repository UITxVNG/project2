extends EnemyState

@export var attack_delay: float = 0.5
var attack_timer: float = 0.0
var shoot_state_timer: float = 0.5
var start_y: float = 0.0

func _enter() -> void:
	obj.change_animation("Shoot")
	attack_timer = attack_delay  
	shoot_state_timer = 0.5

	obj.ignore_gravity = true
	obj.velocity.y = 0.0
	start_y = obj.global_position.y

func _update(delta: float) -> void:
	obj.velocity.y = 0.0
	if attack_timer > 0.0:
		attack_timer -= delta
		if attack_timer <= 0.0:
			obj.attack()

	shoot_state_timer -= delta
	if shoot_state_timer <= 0.0:
		obj.velocity.y = 0.0
		change_state(fsm.previous_state)

	obj.move_and_slide()
	var gp = obj.global_position
	gp.y = start_y
	obj.global_position = gp
