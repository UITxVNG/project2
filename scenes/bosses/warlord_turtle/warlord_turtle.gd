extends StatefulEnemy

@export var idle_time: float = 2.0
@export var spike: float = 0
@export var drop_bomb_time: float = 0.6
@export var drop_period: float = 0.5

@export var launch_time: float = 0.8
@export var stun_time: float = 2.0

var _skill_set = []
var _skill_cursor = 0

@onready var _drop_timer := $DropTimer
@onready var _left_factory := $Direction/LeftFactory
@onready var _right_factory := $Direction/RightFactory
@onready var _rocket_factories := [$RocketPositions/RocketFactory1, $RocketPositions/RocketFactory2, $RocketPositions/RocketFactory3, $RocketPositions/RocketFactory4]

func _ready() -> void:
	super._ready()
	_init_hit_area()
	_init_skill_set()
	_init_drop_bomb_state()
	_init_launch_rocket_state()
	_init_stun_state() 

func _init_stun_state() -> void:
	if has_node("States/Stun"):
		var state : EnemyState = get_node("States/Stun")
		state.enter.connect(start_stun)

func _init_launch_rocket_state() -> void:
	if has_node("States/LaunchRocket"):
		var state : EnemyState = get_node("States/LaunchRocket")
		state.enter.connect(start_launch_rocket)
		state.exit.connect(end_launch_rocket)
		state.update.connect(update_launch_rocket)

func _init_drop_bomb_state() -> void:
	if has_node("States/DropBomb"):
		var state : EnemyState = get_node("States/DropBomb")
		state.enter.connect(start_drop_bomb)
		state.exit.connect(end_drop_bomb)
		state.update.connect(update_drop_bomb)

func _init_hit_area() -> void:
	var hit_area := $Direction/HitArea2D
	hit_area.set_dealt_damage(spike)

func _init_skill_set():
	_skill_set = [fsm.states.dropbomb, fsm.states.launchrocket]
	_skill_cursor = 0

func get_current_skill():
	return _skill_set[_skill_cursor]

func _change_skill():
	_skill_cursor = (_skill_cursor + 1) % _skill_set.size()

func start_normal() -> void:
	_movement_speed = 0
	change_animation("normal")

func start_drop_bomb() -> void:
	_drop_timer.wait_time = drop_period
	_drop_timer.timeout.connect(drop)
	_drop_timer.start()
	change_animation("drop_bomb")
	pass

func end_drop_bomb() -> void:
	_drop_timer.timeout.disconnect(drop)
	_change_skill()
	pass

func update_drop_bomb(_delta) -> void:
	pass

func drop() -> void:
	#var left_bomb := _left_factory.create() as RigidBody2D
	#var right_bomb := _right_factory.create() as RigidBody2D
	#left_bomb.apply_central_impulse(Vector2(movement_speed * _direction_controller.get_direction() * -1, 0.0))
	#right_bomb.apply_central_impulse(Vector2(movement_speed * _direction_controller.get_direction(), 0.0))
	
	var left_bomb := _left_factory.create() as Bullet
	var right_bomb := _right_factory.create() as Bullet
	left_bomb.set_damage(spike)
	right_bomb.set_damage(spike)
	left_bomb.apply_velocity(Vector2(movement_speed * direction * -1, 0.0))
	right_bomb.apply_velocity(Vector2(movement_speed * direction, 0.0))

func start_launch_rocket() -> void:
	change_animation("launch_rocket")
	pass

func end_launch_rocket() -> void:
	_change_skill()
	pass

func update_launch_rocket(_delta) -> void:
	pass

func start_stun() -> void:
	rocket_rain()
	change_animation("stun")
	pass

func rocket_rain() -> void:
	for factory in _rocket_factories:
		var rocket = factory.create() as Bomb
		rocket.set_damage(attack_damage)
		rocket.position.y = 0
