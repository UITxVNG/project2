extends Node

# Target portal name is the name of the portal to which the player will be teleported
var target_portal_name: String = ""

# Checkpoint system variables
var current_checkpoint_id: String = ""
var checkpoint_data: Dictionary = {}
var current_stage: Node = null
var player: Player = null

func _ready() -> void:
	await get_tree().process_frame
	current_stage = get_tree().current_scene
	load_checkpoint_data()
	respawn_at_checkpoint()

# Change stage by path and target portal name
func change_stage(stage_path: String, _target_portal_name: String = "") -> void:
	target_portal_name = _target_portal_name
	get_tree().change_scene_to_file(stage_path)

# Respawn at portal or door
func respawn_at_portal() -> bool:
	if not target_portal_name.is_empty() and current_stage != null:
		var portal = current_stage.find_child(target_portal_name)
		if portal != null and player != null:
			player.global_position = portal.global_position
			target_portal_name = ""
			return true
	return false

func save_checkpoint(checkpoint_id: String) -> void:
	if player == null or current_stage == null:
		return
		
	current_checkpoint_id = checkpoint_id
	var player_state_dict: Dictionary = player.save_state()
	checkpoint_data[checkpoint_id] = {
		"player_state": player_state_dict,
		"stage_path": current_stage.scene_file_path
	}
	print("Checkpoint saved: ", checkpoint_id)

func load_checkpoint(checkpoint_id: String) -> Dictionary:
	if checkpoint_id in checkpoint_data:
		return checkpoint_data[checkpoint_id]
	return {}

func respawn_at_checkpoint() -> void:
	if current_checkpoint_id.is_empty():
		return
	
	var checkpoint_info = checkpoint_data.get(current_checkpoint_id, {})
	if checkpoint_info.is_empty():
		return
	
	var checkpoint_stage = checkpoint_info.get("stage_path", "")
	
	if current_stage != null and current_stage.scene_file_path != checkpoint_stage and not checkpoint_stage.is_empty():
		return
	
	if player == null:
		return
	
	var player_state: Dictionary = checkpoint_info.get("player_state", {})
	if player_state.is_empty():
		return
	
	player.load_state(player_state)

# Check if there is a checkpoint
func has_checkpoint() -> bool:
	return not current_checkpoint_id.is_empty()

# Save checkpoint data to persistent storage
func save_checkpoint_data() -> void:
	var save_data = {
		"current_checkpoint_id": current_checkpoint_id,
		"checkpoint_data": checkpoint_data
	}
	SaveSystem.save_checkpoint_data(save_data)

# Load checkpoint data from persistent storage
func load_checkpoint_data() -> void:
	var save_data = SaveSystem.load_checkpoint_data()
	if not save_data.is_empty():
		current_checkpoint_id = save_data.get("current_checkpoint_id", "")
		checkpoint_data = save_data.get("checkpoint_data", {})

# Clear all checkpoint data
func clear_checkpoint_data() -> void:
	current_checkpoint_id = ""
	checkpoint_data.clear()
	SaveSystem.delete_save_file()
