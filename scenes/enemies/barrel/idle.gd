extends EnemyState


@export var shoot_interval: float = 2.0
var shoot_timer: float = 0.0


func _enter() -> void:
	obj.change_animation("Idle")
	shoot_timer = shoot_interval


func _update(delta: float) -> void:
	if shoot_timer > 0:
		shoot_timer -= delta
	if shoot_timer <= 0:
		change_state(fsm.states.shoot)
