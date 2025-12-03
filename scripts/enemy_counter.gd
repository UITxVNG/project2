extends Node

## Manages enemy defeat tracking and unlocks objects when all enemies are defeated

signal all_enemies_defeated

@export var required_defeats: int = 3  # Số lượng quái cần tiêu diệt
@export var unlock_node_path: NodePath  # Path đến node cần unlock (platform, door, etc.)

var defeated_count: int = 0
var unlock_node: Node = null

func _ready() -> void:
	# Đợi một frame để đảm bảo tất cả nodes đã sẵn sàng
	await get_tree().process_frame
	
	# Lấy reference đến node cần unlock
	if unlock_node_path:
		unlock_node = get_node(unlock_node_path)
		if unlock_node:
			# Ẩn và disable collision của node ban đầu
			_disable_platform(unlock_node)

func register_enemy_defeated() -> void:
	defeated_count += 1
	print("Enemy defeated! Count: %d/%d" % [defeated_count, required_defeats])
	
	if defeated_count >= required_defeats:
		_unlock_object()

func _unlock_object() -> void:
	print("All enemies defeated! Unlocking object...")
	all_enemies_defeated.emit()
	
	if unlock_node:
		# Hiển thị và enable collision
		_enable_platform(unlock_node)
		print("Object unlocked: ", unlock_node.name)

func _disable_platform(node: Node) -> void:
	# Ẩn node
	if node is CanvasItem:
		node.visible = false
	
	# Disable collision cho PathFollow2D/AnimatableBody2D
	if node is Path2D and node.has_node("PathFollow2D/AnimatableBody2D"):
		var body = node.get_node("PathFollow2D/AnimatableBody2D")
		_disable_collision_recursive(body)
	elif node is CollisionObject2D:
		_disable_collision_recursive(node)

func _enable_platform(node: Node) -> void:
	# Hiển thị node với hiệu ứng fade
	if node is CanvasItem:
		node.visible = true
		var tween = create_tween()
		tween.tween_property(node, "modulate:a", 1.0, 0.5).from(0.0)
	
	# Enable collision cho PathFollow2D/AnimatableBody2D
	if node is Path2D and node.has_node("PathFollow2D/AnimatableBody2D"):
		var body = node.get_node("PathFollow2D/AnimatableBody2D")
		_enable_collision_recursive(body)
	elif node is CollisionObject2D:
		_enable_collision_recursive(node)

func _disable_collision_recursive(node: Node) -> void:
	# Disable tất cả CollisionShape2D và CollisionPolygon2D
	for child in node.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", true)
		_disable_collision_recursive(child)

func _enable_collision_recursive(node: Node) -> void:
	# Enable tất cả CollisionShape2D và CollisionPolygon2D
	for child in node.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", false)
		_enable_collision_recursive(child)
