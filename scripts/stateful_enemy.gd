class_name StatefulEnemy
extends EnemyCharacter

func _ready() -> void:
	super._ready()
	fsm=FSM.new(self,$States,$States/Normal)
	_init_normal_state()
	_init_hurt_state()
	_init_dead_state()
	pass

func _init_normal_state() -> void:
	if has_node("States/Normal"):
		var state : EnemyState = get_node("States/Normal")
		state.enter.connect(start_normal)
		state.exit.connect(end_normal)
		state.update.connect(update_normal)

func _init_hurt_state() -> void:
	if has_node("States/Hurt"):
		var state : EnemyState = get_node("States/Hurt")
		state.enter.connect(start_hurt)
		state.exit.connect(end_hurt)
		state.update.connect(update_hurt)

func _init_dead_state() -> void:
	if has_node("States/Dead"):
		var state : EnemyState = get_node("States/Dead")
		state.enter.connect(start_dead)
		state.exit.connect(end_dead)
		state.update.connect(update_dead)

func start_normal() -> void:
	_movement_speed = movement_speed
	change_animation("normal")

func end_normal() -> void:
	pass

func update_normal(_delta: float) -> void:
	try_patrol_turn(_delta)
	pass

func start_hurt() -> void:
	_movement_speed = 0.0
	change_animation("hurt")

func end_hurt() -> void:
	pass

func update_hurt(_delta: float) -> void:
	pass

func start_dead() -> void:
	queue_free()

func end_dead() -> void:
	pass

func update_dead(_delta: float) -> void:
	pass
