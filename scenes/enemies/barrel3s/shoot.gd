extends EnemyState

@export var shoot_delay: float = 0.3 
@export var burst_count: int = 3     
@export var burst_interval: float = 1.5

var shoot_timer: float = 0.0
var bullets_fired: int = 0


func _enter() -> void:
	obj.change_animation("Shoot")
	shoot_timer = 0.2
	bullets_fired = 0
	timer = burst_interval


func _update(delta: float) -> void:
	if shoot_timer > 0:
		shoot_timer -= delta
	else:
		if bullets_fired < burst_count:
			obj.fire() 
			bullets_fired += 1
			shoot_timer = shoot_delay
	if update_timer(delta):
		change_state(fsm.previous_state)
