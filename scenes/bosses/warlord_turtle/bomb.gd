extends Bullet

@export var gravity: float = 700
@export var impulse: Vector2 = Vector2(150, 400)

@onready var _particles_factory := $ParticlesFactory

func _physics_process(_delta: float) -> void:
	if is_on_wall():
		explosion()

func _process(delta: float) -> void:
	velocity.y += gravity * delta
	super._process(delta)

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	explosion()

func explosion() -> void:
	create_particles()
	queue_free()

func create_particles() -> void:
	call_deferred("_create_particles_safe")

func _create_particles_safe() -> void:
	var top_left = _particles_factory.create() as RigidBody2D
	var top_right = _particles_factory.create() as RigidBody2D
	var bot_left = _particles_factory.create() as RigidBody2D
	var bot_right = _particles_factory.create() as RigidBody2D

	top_left.apply_impulse(Vector2(-impulse.x, -impulse.y))
	top_right.apply_impulse(Vector2(impulse.x, -impulse.y))
	bot_left.apply_impulse(Vector2(-impulse.x, -impulse.y / 2))
	bot_right.apply_impulse(Vector2(impulse.x, -impulse.y / 2))

func _on_hurt_area_2d_hurt(direction: Vector2, _damage: float) -> void:
	velocity = direction * abs(velocity)
