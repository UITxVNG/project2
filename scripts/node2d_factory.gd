extends Marker2D
class_name Node2DFactory

signal created(product)

@export var product_packed_scene: PackedScene
@export var target_container_name: StringName

func create(_product_packed_scene := product_packed_scene) -> Node2D:
	var product: Node2D = _product_packed_scene.instantiate()
	product.global_position = global_position
	
	var stage = find_parent("Stage")
	if stage == null:
		push_error("Stage not found. Make sure BulletFactory is inside Stage scene.")
		return null
	
	var container = stage.find_child(target_container_name)
	if container == null:
		push_error("Container '%s' not found under Stage." % target_container_name)
		return null
	
	container.add_child(product)
	created.emit(product)
	return product
