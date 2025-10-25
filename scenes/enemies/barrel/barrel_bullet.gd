extends RigidBody2D

@export var speed: float = 150.0 
@export var max_distance: float = 100.0  

var start_position: Vector2

func _ready() -> void:
	start_position = global_position
	gravity_scale = 0
	linear_velocity = Vector2(speed, 0).rotated(rotation)

func _physics_process(_delta: float) -> void:
	if global_position.distance_to(start_position) > max_distance:
		queue_free()

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	queue_free() 
func _on_body_entered(_body: Node) -> void: 
	queue_free() 
func _on_hit_area_2d_area_entered(_area: Area2D) -> void:
	queue_free()  
func _on_hit_area_2d_body_entered(_body: Node2D) -> void:
	queue_free()  
func _on_hit_area_2d_area_shape_entered(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	queue_free()
	