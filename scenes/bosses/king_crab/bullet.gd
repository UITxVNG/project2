class_name Bullet
extends CharacterBody2D

var _hit_area: HitArea2D = null

func _ready() -> void:
	_init_hit_area()

func _init_hit_area():
	if has_node("Direction/HitArea2D"):
		_hit_area = $Direction/HitArea2D
	elif has_node("HitArea2D"):
		_hit_area = $HitArea2D

func _process(_delta: float) -> void:
	move_and_slide()

func set_damage(damage: float) -> void:
	_hit_area.set_dealt_damage(damage)

func apply_velocity(fire_velocity: Vector2) -> void:
	velocity = fire_velocity
