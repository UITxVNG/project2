extends StatefulEnemy

@export var rolling_time: float = 2.0
@export var stop_rolling_time: float = 0.4
@export var idle_time: float = 2.0
@export var shoot_period: float = 0.6
@export var recall_time: float = 0.4
@export var stun_time: float = 2.0
@export var attack_range: float = 150.0
@export var spike: float = 0

var _skill_set = []
var _skill_cursor = 0

var _is_attaching := false

@onready var _roll_box := $Direction/HitArea2D/CollisionShape2D
@onready var bullet_factory := $Direction/BulletFactory
@onready var _action_timer := $ActionTimer

func _ready() -> void:
	super._ready();
	_init_skill_set()
	_init_roll_state()
	_init_stop_roll_state()
	_init_shoot_state()
	_init_recall_state()
	_init_stun_state()

func _init_stun_state() -> void:
	if has_node("States/Stun"):
		var state : EnemyState = get_node("States/Stun")
		state.enter.connect(start_stun)

func _init_recall_state() -> void:
	if has_node("States/Recall"):
		var state : EnemyState = get_node("States/Recall")
		state.enter.connect(start_recall)
		state.exit.connect(end_recall)

func _init_shoot_state() -> void:
	if has_node("States/Shoot"):
		var state : EnemyState = get_node("States/Shoot")
		state.enter.connect(start_shoot)
		state.exit.connect(end_shoot)

func _init_stop_roll_state() -> void:
	if has_node("States/Roll"):
		var state : EnemyState = get_node("States/Roll")
		state.enter.connect(start_roll)
		state.exit.connect(end_roll)

func _init_roll_state() -> void:
	if has_node("States/StopRoll"):
		var state : EnemyState = get_node("States/StopRoll")
		state.enter.connect(start_stop_roll)

func _init_skill_set():
	_skill_set = [fsm.states.roll, fsm.states.shoot]
	_skill_cursor = 0

func start_roll() -> void:
	_roll_box.disabled = false;
	_movement_speed = movement_speed;
	change_animation("roll");
	pass

func end_roll() -> void:
	_roll_box.disabled = true;
	_change_skill()
	pass

func start_stop_roll() -> void:
	_movement_speed = 0;
	change_animation("stop_roll");
	pass

func start_normal() -> void:
	_movement_speed = movement_speed / 2
	change_animation("normal")

func update_normal(_delta: float) -> void:
	if is_can_fall() or is_touch_wall():
		turn_around()
	pass
	
func start_shoot() -> void:
	_movement_speed = 0
	
	_action_timer.wait_time = shoot_period
	_action_timer.start()
	_action_timer.timeout.connect(shoot)
	
	change_animation("shoot")

func end_shoot() -> void:
	_action_timer.timeout.disconnect(shoot)
	_change_skill()
	pass

func start_recall() -> void:
	_movement_speed = 0
	change_animation("recall")

func end_recall() -> void:
	_is_attaching = false
	pass

func start_stun() -> void:
	_movement_speed = 0
	change_animation("stun")

func get_current_skill():
	return _skill_set[_skill_cursor]

func _change_skill():
	_skill_cursor = (_skill_cursor + 1) % _skill_set.size()

func shoot() -> void:
	var bullet := bullet_factory.create() as Claw
	bullet.set_damage(spike)
	bullet.apply_velocity(Vector2(movement_speed, 0.0))
	bullet.set_direction(direction)
	bullet.set_range(attack_range)

func is_attaching() -> bool:
	return _is_attaching

func _on_recall_area_2d_body_entered(body: Node2D) -> void:
	if body is Claw:
		var claw := body as Claw
		_is_attaching = true
		claw.attach()


func _on_hit_area_2d_hitted(area: Variant) -> void:
	pass # Replace with function body.
