extends Node

# === Portal & Stage System ===
# Target portal name is the name of the portal to which the player will be teleported
var target_portal_name: String = ""
var current_stage: Node = null
var should_respawn_at_checkpoint: bool = false
var pending_teleport: bool = false
var is_initial_load: bool = true  # Track if this is the first load

# === Checkpoint System ===
var current_checkpoint_id: String = ""
var checkpoint_data: Dictionary = {}
var last_checkpoint_position: Vector2 = Vector2.ZERO

# === Reference đến Player ===
var player: Player = null
var inventory_system: InvetorySystem = null

# === Trạng thái vật phẩm ===
var has_blade: bool = false
var has_hammer: bool = false

var artifacts_collected: int = 0
var total_artifacts: int = 7
var souls_collected: int = 0
var current_map: int = 1

# === Trạng thái cốt truyện ===
var story_flags: Dictionary = {
	"intro_seen": false,
	"mush_met": false,
	"crabbo_met": false,
	"first_boss_defeated": false,
	"truth_discovered": false,
	"dark_voice_revealed": false,
	"final_choice_made": false
}

# === Tracking cho endings ===
var enemies_killed: int = 0
var npcs_helped: int = 0
var warnings_ignored: int = 0

# === Signals ===
signal artifact_collected(count: int)
signal story_flag_changed(flag_name: String, value: bool)
signal map_changed(map_number: int)
signal blade_collected()

func _ready() -> void:
	load_checkpoint_data()
	
	# Connect to scene changes first
	get_tree().node_added.connect(_on_node_added)
	
	# Defer checkpoint loading to avoid scene tree conflicts
	call_deferred("_check_initial_checkpoint")
	
	# Init inventory system
	inventory_system = InvetorySystem.new()
	add_child(inventory_system)
	
	# Kết nối với Dialogic signals
	Dialogic.signal_event.connect(_on_dialogic_signal)

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
		# Restore vũ khí đúng lúc
		call_deferred("_restore_player_equipment")

		# Handle pending actions
		if should_respawn_at_checkpoint:
			call_deferred("respawn_at_checkpoint")
			should_respawn_at_checkpoint = false
		elif pending_teleport and not target_portal_name.is_empty():
			call_deferred("respawn_at_portal")
			pending_teleport = false
func _restore_player_equipment():
	if player == null:
		return

	if has_blade:
		player.collected_blade()

	if has_hammer:
		player.collected_hammer()

# =============================================================================
# STAGE & PORTAL SYSTEM
# =============================================================================

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

func change_map(map_number: int) -> void:
	current_map = map_number
	map_changed.emit(map_number)

# =============================================================================
# CHECKPOINT SYSTEM
# =============================================================================

func save_checkpoint(checkpoint_id: String) -> void:
	if current_stage == null:
		current_stage = get_tree().current_scene
	
	if player == null or current_stage == null:
		print("Cannot save checkpoint: player or stage is null")
		return
	
	current_checkpoint_id = checkpoint_id
	last_checkpoint_position = player.global_position
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

# =============================================================================
# ITEM & COLLECTIBLE SYSTEM
# =============================================================================

func collected_blade() -> void:
	if not has_blade:
		has_blade = true
		if player != null:
			player.collect_powerup("blade")
		print("Foxy đã nhận được thanh kiếm!")
		
		# Gọi hàm trong player để trang bị kiếm
		if player != null and player.has_method("collected_blade"):
			player.collected_blade()
		
		blade_collected.emit()
func collected_hammer() -> void:
	if not has_hammer:
		has_hammer = true
		if player != null:
			player.collected_hammer()
		
		print("Foxy đã nhận được cây búa!")

func collect_artifact() -> void:
	artifacts_collected += 1
	artifact_collected.emit(artifacts_collected)
	
	# Kích hoạt thay đổi môi trường dựa trên số artifact
	_check_world_corruption()
	
	print("Di vật thu thập: %d/%d" % [artifacts_collected, total_artifacts])

func collect_soul() -> void:
	souls_collected += 1

# =============================================================================
# STORY FLAG SYSTEM
# =============================================================================

func set_story_flag(flag_name: String, value: bool = true) -> void:
	if flag_name in story_flags:
		story_flags[flag_name] = value
		story_flag_changed.emit(flag_name, value)
		print("Story flag set: %s = %s" % [flag_name, value])

func get_story_flag(flag_name: String) -> bool:
	return story_flags.get(flag_name, false)

# =============================================================================
# ENDING SYSTEM
# =============================================================================

func get_artifact_percentage() -> float:
	return (float(artifacts_collected) / float(total_artifacts)) * 100.0

func should_get_bad_ending() -> bool:
	return get_artifact_percentage() >= 70.0 and story_flags.get("final_choice_made", false)

func should_get_good_ending() -> bool:
	var percentage = get_artifact_percentage()
	return percentage >= 30.0 and percentage < 70.0

func should_get_secret_ending() -> bool:
	return get_artifact_percentage() < 29.0

# =============================================================================
# DIALOGIC INTEGRATION
# =============================================================================

func _on_dialogic_signal(argument: String) -> void:
	match argument:
		"collected_blade":
			collected_blade()
		"collect_artifact":
			collect_artifact()
		"ignore_warning":
			warnings_ignored += 1
		"help_npc":
			npcs_helped += 1
		"reveal_truth":
			set_story_flag("truth_discovered", true)
		"dark_voice_appears":
			set_story_flag("dark_voice_revealed", true)
		_:
			print("Dialogic signal không xác định: " + argument)

# =============================================================================
# WORLD CORRUPTION SYSTEM
# =============================================================================

func _check_world_corruption() -> void:
	# Map 6 trở đi: thế giới bắt đầu suy tàn
	if artifacts_collected >= 3 and current_map >= 6:
		_trigger_world_decay()

func _trigger_world_decay() -> void:
	# Thay đổi màu sắc, weather, âm nhạc
	print("Thế giới bắt đầu suy tàn...")
	# Có thể gọi WorldEnvironment để thay đổi

# =============================================================================
# PLAYER CONTROL
# =============================================================================

func set_player_can_move(can_move: bool) -> void:
	"""Điều khiển di chuyển của player - tương thích với FSM"""
	if player == null:
		push_warning("GameManager: Player chưa được set!")
		return
	
	# Nếu player có FSM
	if player.has_method("set_can_move"):
		player.set_can_move(can_move)
	else:
		# Fallback: disable/enable processing
		player.set_physics_process(can_move)
		player.set_process_input(can_move)

func freeze_player() -> void:
	"""Dừng player lại hoàn toàn (cho cutscene)"""
	if player == null:
		return
	
	player.velocity = Vector2.ZERO
	set_player_can_move(false)

func unfreeze_player() -> void:
	"""Cho phép player di chuyển lại"""
	set_player_can_move(true)

# =============================================================================
# SAVE/LOAD GAME STATE
# =============================================================================

func save_game() -> void:
	var save_data = {
		"has_blade": has_blade,
		"has_hammer": has_hammer,
		"artifacts_collected": artifacts_collected,
		"souls_collected": souls_collected,
		"current_map": current_map,
		"story_flags": story_flags,
		"enemies_killed": enemies_killed,
		"npcs_helped": npcs_helped,
		"warnings_ignored": warnings_ignored
	}
	
	# Lưu player position nếu có
	if player != null:
		save_data["player_position"] = {
			"x": player.global_position.x,
			"y": player.global_position.y
		}
	
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Game đã được lưu!")
	else:
		push_error("Không thể tạo file save!")

func load_game() -> void:
	if not FileAccess.file_exists("user://savegame.save"):
		print("Không tìm thấy file save!")
		return
	
	var file = FileAccess.open("user://savegame.save", FileAccess.READ)
	if not file:
		push_error("Không thể mở file save!")
		return
	
	var save_data = file.get_var()
	file.close()
	
	has_blade = save_data.get("has_blade", false)
	has_hammer = save_data.get("has_hammer", false)
	artifacts_collected = save_data.get("artifacts_collected", 0)
	souls_collected = save_data.get("souls_collected", 0)
	current_map = save_data.get("current_map", 1)
	story_flags = save_data.get("story_flags", {})
	enemies_killed = save_data.get("enemies_killed", 0)
	npcs_helped = save_data.get("npcs_helped", 0)
	warnings_ignored = save_data.get("warnings_ignored", 0)
	
	# Restore player position
	if player != null and save_data.has("player_position"):
		var pos = save_data["player_position"]
		player.global_position = Vector2(pos["x"], pos["y"])
	
	# Update player blade status
	if has_blade and player != null and player.has_method("collected_blade"):
		player.collected_blade()
	if has_hammer and player != null and player.has_method("collected_hammer"):
		player.collected_hammer()

	print("Game đã được load!")

# =============================================================================
# DEBUG & RESET FUNCTIONS
# =============================================================================

func reset_game() -> void:
	"""Reset toàn bộ game state"""
	has_blade = false
	artifacts_collected = 0
	souls_collected = 0
	current_map = 1
	enemies_killed = 0
	npcs_helped = 0
	warnings_ignored = 0
	
	for key in story_flags.keys():
		story_flags[key] = false
	
	print("Game state đã được reset!")

func print_debug_info() -> void:
	"""In thông tin debug"""
	print("\n=== GAME MANAGER DEBUG ===")
	print("Has Blade: ", has_blade)
	print("Artifacts: %d/%d (%.1f%%)" % [artifacts_collected, total_artifacts, get_artifact_percentage()])
	print("Souls: ", souls_collected)
	print("Current Map: ", current_map)
	print("Story Flags: ", story_flags)
	print("Enemies Killed: ", enemies_killed)
	print("NPCs Helped: ", npcs_helped)
	print("Warnings Ignored: ", warnings_ignored)
	print("Player Reference: ", "Valid" if player != null else "NULL")
	print("Current Checkpoint: ", current_checkpoint_id if not current_checkpoint_id.is_empty() else "None")
	print("========================\n")
