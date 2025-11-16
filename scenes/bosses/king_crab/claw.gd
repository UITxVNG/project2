class_name Claw
extends Bullet


@onready var _direction_controller = DirectionController.new($Direction)
@onready var _animation := $Direction/AnimatedSprite2D
@onready var _patrol_controller = PatrolController.new(100)

func _ready() -> void:
	super._ready()
	_animation.play()
	_patrol_controller.set_start_position(position.x)

func _process(delta: float) -> void:
	update_velocity()
	move_and_slide()
	
	if _patrol_controller.track_patrol(position.x, _direction_controller.get_direction()):
		_direction_controller.turn_around()
	
	_direction_controller._update(delta)

func _on_hit_area_2d_hitted(_area: Variant) -> void:	
	_direction_controller.turn_around()

func update_velocity() -> void:
	velocity.x = abs(velocity.x) * _direction_controller.get_direction()

func set_direction(direction: int) -> void:
	_direction_controller.change_direction(direction)

func attach() -> void:
	queue_free()

func _on_hit_area_2d_body_entered(_body: Node2D) -> void:
	_direction_controller.turn_around()

func set_range(_range: float) -> void:
	_patrol_controller.set_movement_range(_range)
