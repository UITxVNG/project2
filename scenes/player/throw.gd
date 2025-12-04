extends PlayerState

@export var blade_scene: PackedScene
@export var blade_speed: float = 1000.0
@export var throw_delay: float = 0.2

var throw_timer: float = 0.0

func _enter() -> void:
	if not obj.has_blade:
		change_state(fsm.states.idle)
		return
	
	obj.change_animation("attack")
	throw_timer = throw_delay
	timer = 0.6
	obj.velocity.x = 0

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	# Ném lưỡi kiếm sau throw_delay
	if throw_timer > 0:
		throw_timer -= delta
		if throw_timer <= 0:
			obj.throw_blade(blade_speed)
	
	# Quay lại state trước đó khi hết timer
	if update_timer(delta):
		change_state(fsm.previous_state)
