# scripts/maps/map3.gd
extends Node2D

@export var next_map_path: String = "res://scenes/maps/map4_mystery_cave.tscn"

@onready var puzzle = $PuzzleArea/RunePuzzle
@onready var artifact_spawn = $Collectibles/Artifact3
@onready var world_env = $WorldEnvironment
@onready var canvas_modulate = $Lighting

var puzzle_solved: bool = false

func _ready() -> void:
	# Set current map
	GameManager.change_map(3)
	
	# Ẩn artifact ban đầu
	if artifact_spawn:
		artifact_spawn.visible = false
		artifact_spawn.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Connect puzzle signal
	if puzzle:
		puzzle.puzzle_solved.connect(_on_puzzle_solved)
	
	# Check nếu đã thu thập artifact 3
	if GameManager.has_artifact(3):
		# Puzzle đã giải, mở cửa
		if puzzle:
			puzzle.is_solved = true
			puzzle._open_door()

func _on_puzzle_solved() -> void:
	puzzle_solved = true
	print("Map3: Puzzle solved!")
	
	# Wait cho animation door open
	await get_tree().create_timer(2.0).timeout
	
	# Spawn artifact
	if artifact_spawn:
		artifact_spawn.visible = true
		artifact_spawn.process_mode = Node.PROCESS_MODE_INHERIT
		
		# Animation spawn
		artifact_spawn.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(artifact_spawn, "scale", Vector2.ONE, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _trigger_world_darkening() -> void:
	"""Làm tối thế giới khi có 3 artifacts"""
	if GameManager.artifacts_collected >= 3:
		var tween = create_tween()
		
		# Giảm brightness
		if world_env and world_env.environment:
			tween.tween_property(world_env.environment, "adjustment_brightness", 0.9, 3.0)
		
		# Giảm saturation
		if canvas_modulate:
			tween.tween_property(canvas_modulate, "color", Color(0.95, 0.95, 1.0), 3.0)
