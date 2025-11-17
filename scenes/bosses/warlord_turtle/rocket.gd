class_name Bomb
extends RigidBody2D

@onready var _hit_area: HitArea2D = $HitArea2D

func set_damage(damage: float) -> void:
	_hit_area.set_dealt_damage(damage)


@export var impulse: Vector2 = Vector2(150, 400)

@onready var _particles_factory := $ParticlesFactory

func _ready():
	contact_monitor = true
	max_contacts_reported = 4

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var bodies = state.get_contact_count()

	for i in bodies:
		var collider = state.get_contact_collider_object(i)
		if collider:
			explosion()
		return


func _on_hit_area_2d_body_entered(_body: Node2D) -> void:
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

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	explosion()

func _on_body_entered(body: Node) -> void:
	explosion()
