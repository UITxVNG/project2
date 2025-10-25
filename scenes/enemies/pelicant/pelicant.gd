extends EnemyCharacter
@export var bullet_speed: float = 200
@onready var bullet_factory := $Direction/BulletFactory
@export var fly_speed: float = 100.0
@export var fly_distance: float = 200.0
func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Idle)
	super._ready()

func fire() -> void:
	var bullet := bullet_factory.create() as RigidBody2D
	var shooting_velocity := Vector2(bullet_speed * direction, 0.0)
	bullet.apply_impulse(shooting_velocity)
