extends Node2D

@export_file("*.tscn") var target_stage = ""
@export var target_door = "Door"

func load_next_stage():
	# Check if target_stage is empty or same as current stage
	if target_stage == "" or target_stage == get_tree().current_scene.scene_file_path:
		# Same stage - just teleport player to target door
		teleport_player()
	else:
		# Different stage - load new stage
		GameManager.change_stage(target_stage, target_door)

func teleport_player():
	# Find the target door in current stage
	var doors = get_tree().get_nodes_in_group("doors")
	for door in doors:
		if door.name == target_door:
			# Move player to target door position
			var player = get_tree().get_first_node_in_group("Player")
			if player:
				player.global_position = door.global_position
			break

func _on_interactive_area_2d_interacted() -> void:
	load_next_stage()
