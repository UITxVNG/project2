extends EnemyState
@export var attack_movement_speed = 200
var time_prepare:float = 0.3
func _enter() -> void:
	obj.change_animation("attack")
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = false
	timer = 1.2
	time_prepare = 0.3
	obj.velocity.x = 0

func _exit() -> void:
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = true

func _update(delta: float) -> void:
	time_prepare -= delta

	# ⚠️ NGĂN rơi khỏi map
	if _should_turn_around():
		obj.velocity.x = 0
		change_state(fsm.previous_state)
		return

	if time_prepare < 0:
		obj.velocity.x = obj.direction * attack_movement_speed

	if update_timer(delta):
		change_state(fsm.previous_state)


func _should_turn_around() -> bool:
	if obj.is_touch_wall():
		return true
	if obj.is_on_floor() and obj.is_can_fall():
		return true
	return false
