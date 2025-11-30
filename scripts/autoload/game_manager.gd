extends Node

# Target portal name is the name of the portal to which the player will be teleported
var target_portal_name: String = ""
# Checkpoint system variables
var current_checkpoint_id: String = ""
var checkpoint_data: Dictionary = {}
var current_stage: Node = null
var player: Player = null
var should_respawn_at_checkpoint: bool = false
var pending_teleport: bool = false
var is_initial_load: bool = true  # Track if this is the first load

var inventory_system: InvetorySystem = null

func _ready() -> void:
	load_checkpoint_data()
	
	# Connect to scene changes first
	get_tree().node_added.connect(_on_node_added)
	
	# Defer checkpoint loading to avoid scene tree conflicts
	call_deferred("_check_initial_checkpoint")
	
	#Init inventory system
	inventory_system = InvetorySystem.new()
	add_child(inventory_system)
	pass

func _check_initial_checkpoint() -> void:
	# Check if we have a checkpoint and this is initial project load
	if is_initial_load and has_checkpoint():
		print("Checkpoint found on project load, preparing to respawn")
		# Load the stage from checkpoint
		var checkpoint_info = checkpoint_data.get(current_checkpoint_id, {})
		if not checkpoint_info.is_empty():
			var checkpoint_stage = checkpoint_info.get("stage_path", "")
			if not checkpoint_stage.is_empty():
				should_respawn_at_checkpoint = true
				# Change to the checkpoint's stage
				get_tree().change_scene_to_file(checkpoint_stage)
		is_initial_load = false
	else:
		is_initial_load = false

func _on_node_added(node: Node) -> void:
	# When player is added to scene, check if we need to teleport
	if node is Player:
		player = node
		current_stage = get_tree().current_scene
		print("Player detected in scene")
		
		# Handle pending actions
		if should_respawn_at_checkpoint:
			call_deferred("respawn_at_checkpoint")
			should_respawn_at_checkpoint = false
		elif pending_teleport and not target_portal_name.is_empty():
			call_deferred("respawn_at_portal")
			pending_teleport = false

func change_stage(stage_path: String, _target_portal_name: String = "") -> void:
	target_portal_name = _target_portal_name
	should_respawn_at_checkpoint = false
	pending_teleport = not target_portal_name.is_empty()
	current_stage = null
	player = null
	is_initial_load = false  # No longer initial load after first stage change
	# Change scene to stage path
	get_tree().change_scene_to_file(stage_path)

# Respawn at portal or door
func respawn_at_portal() -> bool:
	if target_portal_name.is_empty():
		return false
	
	if current_stage == null:
		current_stage = get_tree().current_scene
	
	if player == null:
		print("Player not ready yet for teleport")
		return false
	
	if current_stage != null:
		var portal = current_stage.find_child(target_portal_name, true, false)
		if portal != null:
			# Use call_deferred to ensure physics is ready
			await get_tree().process_frame
			player.global_position = portal.global_position
			print("Player teleported to: ", target_portal_name, " at position: ", portal.global_position)
			target_portal_name = ""
			pending_teleport = false
			return true
		else:
			print("Portal not found: ", target_portal_name)
	
	target_portal_name = ""
	pending_teleport = false
	return false

func save_checkpoint(checkpoint_id: String) -> void:
	if current_stage == null:
		current_stage = get_tree().current_scene
	
	if player == null or current_stage == null:
		print("Cannot save checkpoint: player or stage is null")
		return
	
	current_checkpoint_id = checkpoint_id
	var player_state_dict: Dictionary = player.save_state()
	checkpoint_data[checkpoint_id] = {
		"player_state": player_state_dict,
		"stage_path": current_stage.scene_file_path
	}
	print("Checkpoint saved: ", checkpoint_id)
	save_checkpoint_data()

func load_checkpoint(checkpoint_id: String) -> Dictionary:
	if checkpoint_id in checkpoint_data:
		return checkpoint_data[checkpoint_id]
	return {}

func respawn_at_checkpoint() -> void:
	if current_checkpoint_id.is_empty():
		print("No checkpoint to respawn at")
		return
	
	var checkpoint_info = checkpoint_data.get(current_checkpoint_id, {})
	if checkpoint_info.is_empty():
		print("Checkpoint info empty")
		return
	
	if player == null:
		print("Player not found for checkpoint respawn")
		return
	
	# Check if we need to load a different stage
	var checkpoint_stage = checkpoint_info.get("stage_path", "")
	if current_stage == null:
		current_stage = get_tree().current_scene
	
	if current_stage != null and current_stage.scene_file_path != checkpoint_stage and not checkpoint_stage.is_empty():
		# Need to load different stage first
		print("Checkpoint is in different stage: ", checkpoint_stage)
		should_respawn_at_checkpoint = true
		change_stage(checkpoint_stage, "")
		return
	
	# Load player state
	var player_state: Dictionary = checkpoint_info.get("player_state", {})
	if player_state.is_empty():
		print("Player state empty")
		return
	
	await get_tree().process_frame
	player.load_state(player_state)
	print("Player respawned at checkpoint: ", current_checkpoint_id)
	print("Player position: ", player.global_position)

# Call this when player dies to respawn at checkpoint
func player_died() -> void:
	should_respawn_at_checkpoint = true
	if current_stage != null:
		get_tree().reload_current_scene()
	else:
		# If we don't have stage info, load from checkpoint data
		if not current_checkpoint_id.is_empty():
			var checkpoint_info = checkpoint_data.get(current_checkpoint_id, {})
			var checkpoint_stage = checkpoint_info.get("stage_path", "")
			if not checkpoint_stage.is_empty():
				change_stage(checkpoint_stage, "")

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
	print("Checkpoint data saved to file")

# Load checkpoint data from persistent storage
func load_checkpoint_data() -> void:
	var save_data = SaveSystem.load_checkpoint_data()
	if not save_data.is_empty():
		current_checkpoint_id = save_data.get("current_checkpoint_id", "")
		checkpoint_data = save_data.get("checkpoint_data", {})
		print("Checkpoint data loaded: ", current_checkpoint_id)

# Clear all checkpoint data
func clear_checkpoint_data() -> void:
	current_checkpoint_id = ""
	checkpoint_data.clear()
	SaveSystem.delete_save_file()
	print("All checkpoint data cleared")
