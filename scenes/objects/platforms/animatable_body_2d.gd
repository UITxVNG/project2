extends AnimatableBody2D

@export var path_follow: PathFollow2D
@export var move_speed: float = 100.0

var velocity: Vector2 = Vector2.ZERO
var _dbg_frame_counter: int = 0

func _ready():
	sync_to_physics = true

	# Resolve a NodePath assignment from the scene to the actual node (use get() to avoid static typing issues)
	var raw_pf = null
	# try to read the exported property raw value
	if has_method("get"):
		raw_pf = get("path_follow")
	# If the scene set a NodePath, resolve it
	if typeof(raw_pf) == TYPE_NODE_PATH:
		var resolved = get_node(raw_pf)
		if resolved:
			path_follow = resolved

	# If still null, try parent (common setup: AnimatableBody2D is child of PathFollow2D)
	if path_follow == null:
		var p = get_parent()
		print("[AnimatableBody2D] parent=", p)
		if p and p is PathFollow2D:
			path_follow = p

	# Debug: report what we have for path_follow
	if Engine.is_editor_hint():
		print("[AnimatableBody2D] editor: path_follow=", path_follow)
	else:
		print("[AnimatableBody2D] ready: path_follow=", path_follow, " move_speed=", move_speed)

func _physics_process(delta):
	if path_follow == null or move_speed == 0:
		constant_linear_velocity = Vector2.ZERO
		return
	
	# Store old position
	var old_position = path_follow.global_position
	
	# Move path follow (move_speed is treated as units per second along the path)
	path_follow.progress += move_speed * delta

	# Debug traces to help diagnose movement issues (print roughly once per second)
	_dbg_frame_counter += 1
	if _dbg_frame_counter % 60 == 0:
		print("[AnimatableBody2D] progress=", path_follow.progress, " progress_ratio=", path_follow.progress_ratio, " new_pos=", path_follow.global_position)
	
	# Calculate new position and velocity
	var new_position = path_follow.global_position
	velocity = (new_position - old_position) / delta
	
	# Update platform velocity BEFORE moving
	constant_linear_velocity = velocity
