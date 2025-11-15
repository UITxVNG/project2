extends EnemyCharacter
@export var hide_duration: float = 3.0
var hiding: bool = false
@export var move_range: float = 200.0
@export var speed: float = 50.0
var start_x: float
var can_turn: bool = true
@onready var front_ray = $Direction/FrontRayCast2D

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	start_x = global_position.x
	super._ready()
	get_node("HitArea2D/CollisionShape2D").disabled = true




#func hide_in_shell():
	#fsm.change_state(fsm.states.hide)
