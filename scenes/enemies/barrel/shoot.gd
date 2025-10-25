extends EnemyState

@export var shoot_delay: float = 1.0
@export var duration: float = 1.0
var shoot_timer: float = 0.0

func _enter() -> void:
	obj.change_animation("Shoot")
	shoot_timer = 0.0
	timer = duration

func _update(delta: float) -> void:
	if shoot_timer > 0.0:
		shoot_timer -= delta
	else:
		if obj != null and obj.has_method("fire"):
			obj.fire()
		shoot_timer = shoot_delay

	# sử dụng hàm của lớp cha nếu có
	if update_timer(delta):  # giả sử update_timer giảm timer và trả về true khi hết
		change_state(fsm.previous_state)
