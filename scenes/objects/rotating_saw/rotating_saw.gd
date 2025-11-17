extends Path2D

## Rotating saw blade that moves along a path and damages the player

@export var move_speed: float = 100.0  # Tốc độ di chuyển dọc theo path
@export var rotation_speed: float = 360.0  # Tốc độ quay (độ/giây)
@export var damage: int = 1  # Sát thương gây ra

@onready var path_follow = $PathFollow2D
@onready var saw_blade = $PathFollow2D/SawBlade
@onready var hit_area = $PathFollow2D/SawBlade/HitArea2D

func _ready() -> void:
	if hit_area:
		hit_area.body_entered.connect(_on_hit_area_body_entered)

func _process(delta: float) -> void:
	# Di chuyển dọc theo path
	if path_follow:
		path_follow.progress += move_speed * delta
	
	# Quay bánh răng
	if saw_blade:
		saw_blade.rotation_degrees += rotation_speed * delta

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.has_method("take_damage"):
		body.take_damage(damage)
