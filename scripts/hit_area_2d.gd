extends Area2D
class_name HitArea2D

@export var damage = 1.0
signal hitted(area)
var _dealt_damage: float = 1

func _init():
	self.area_entered.connect(_on_area_entered)
	self.body_entered.connect(_on_body_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		var hit_dir: Vector2 = area.global_position - global_position
		area.take_damage(hit_dir.normalized(), damage)
	emit_signal("hitted", area)
	
func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		var hit_dir: Vector2 = body.global_position - global_position
		body.take_damage(hit_dir.normalized(), damage)  # Call take_damage on the body
	emit_signal("hitted", body)

func set_dealt_damage(dealt_damage: float) -> void:
	_dealt_damage = dealt_damage
