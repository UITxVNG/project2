extends RigidBody2D

@export var speed: float = 900.0
@export var return_delay: float = 0.25
@export var return_speed: float = 1100.0
@export var damage: int = 1

var direction := 1
var player: Player
var returning := false

var start_position: Vector2
var max_distance := 400.0
var return_distance := 25.0


func _ready() -> void:
	# Play animation
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play()

	# Hit detection
	if has_node("HitArea2D"):
		$HitArea2D.hitted.connect(_on_hit_area_2d_hitted)

	start_position = global_position

	# Fly straight for a while before returning
	linear_velocity = Vector2(direction * speed, 0)

	await get_tree().create_timer(return_delay).timeout
	returning = true


func _physics_process(delta: float) -> void:
	if player == null:
		queue_free()
		return

	if returning:
		# Move toward player
		var dir = (player.global_position - global_position).normalized()
		linear_velocity = dir * return_speed

		# Rotate for boomerang effect
		rotation += delta * 20.0

		# Catch when close
		if global_position.distance_to(player.global_position) <= return_distance:
			if player.has_method("catch_blade"):
				player.catch_blade()
			queue_free()
	else:
		# Moving outward
		linear_velocity = Vector2(direction * speed, 0)

		# Too far → auto return
		if global_position.distance_to(start_position) >= max_distance:
			returning = true


func _on_hit_area_2d_hitted(hit_area):
	if not returning:
		# Damage enemy
		var obj = hit_area.get_parent()
		if obj and obj.has_method("take_damage"):
			obj.take_damage(damage)

		# Start returning instead of disappearing
		returning = true
