extends EnemyState

@export var shoot_interval: float = 2.0
var shoot_timer: float = 0.0
var start_x: float = 0.0
var start_y: float = 0.0
@export var fly_speed: float = 100.0
@export var fly_distance: float = 200.0

func _enter() -> void:
	obj.change_animation("Idle")
	shoot_timer = shoot_interval
	start_x = obj.global_position.x
	start_y = obj.global_position.y

	obj.ignore_gravity = true
	obj.velocity.y = 0.0

func _update(delta: float) -> void:
	if shoot_timer > 0.0:
		shoot_timer -= delta
	if shoot_timer <= 0.0:
		obj.velocity.y = 0.0
		change_state(fsm.states.shoot)

	obj.velocity.x = obj.direction * fly_speed
	obj.velocity.y = 0.0

	if _should_turn_around():
		obj.turn_around()
		start_x = obj.global_position.x
	obj.move_and_slide()

	var gp = obj.global_position
	gp.y = start_y
	obj.global_position = gp

func _should_turn_around() -> bool:
	if obj.is_touch_wall():
		return true
	if abs(obj.global_position.x - start_x) >= fly_distance:
		return true
	return false
