# game_manager.gd - MERGED VERSION
extends Node

# =============================================================================
# PRELOADS & CONSTANTS
# =============================================================================
const InventorySystem = preload("res://scripts/inventory_system.gd")
const SAVE_FILE = "user://checkpoint_save.dat"

# =============================================================================
# PORTAL & STAGE SYSTEM
# =============================================================================
var target_portal_name: String = ""
var current_stage: Node = null
var should_respawn_at_checkpoint: bool = false
var pending_teleport: bool = false
var is_initial_load: bool = true

# =============================================================================
# CHECKPOINT SYSTEM
# =============================================================================
var current_checkpoint_id: String = ""
var checkpoint_data: Dictionary = {}
var last_checkpoint_position: Vector2 = Vector2.ZERO

# =============================================================================
# PLAYER & INVENTORY REFERENCE
# =============================================================================
var player: Player = null
var inventory_system: InventorySystem = null

# =============================================================================
# ITEM STATE (VŨ KHÍ & VẬT PHẨM)
# =============================================================================
var has_blade: bool = false
var has_hammer: bool = false

# =============================================================================
# ARTIFACT SYSTEM
# =============================================================================
var artifacts_collected: int = 0
var total_artifacts: int = 7
var souls_collected: int = 0

# Tracking artifact IDs đã thu thập (để không spawn lại)
var collected_artifact_ids: Array[int] = []

# Thông tin chi tiết từng artifact
var artifact_data: Dictionary = {
	1: {"name": "Ngọc Triều Cường", "map": 1},
	2: {"name": "Vỏ Sò Thần Bí", "map": 2},
	3: {"name": "Răng Cá Mập Cổ", "map": 3},
	4: {"name": "San Hô Phát Sáng", "map": 5},
	5: {"name": "Trái Tim Rùa Biển", "map": 6},
	6: {"name": "Mắt Bạch Tuộc Khổng Lồ", "map": 8},
	7: {"name": "Vảy Rồng Biển", "map": 9}
}

# =============================================================================
# STORY FLAGS
# =============================================================================
var current_map: int = 1
var story_flags: Dictionary = {
	"intro_seen": false,
	"mush_met": false,
	"crabbo_met": false,
	"first_boss_defeated": false,
	"truth_discovered": false,
	"dark_voice_revealed": false,
	"final_choice_made": false,
	"first_artifact_collected": false,
	"world_corruption_started": false,
	"npcs_fear_player": false,
	"all_artifacts_collected": false
}

# =============================================================================
# ENDING TRACKING
# =============================================================================
var enemies_killed: int = 0
var npcs_helped: int = 0
var warnings_ignored: int = 0

# =============================================================================
# SIGNALS
# =============================================================================
signal artifact_collected(count: int)
signal story_flag_changed(flag_name: String, value: bool)
signal map_changed(map_number: int)
signal blade_collected()

# =============================================================================
# INITIALIZATION
# =============================================================================
func _ready() -> void:
	# Load checkpoint data first
	load_checkpoint_data()
	
	# Connect to scene changes
	get_tree().node_added.connect(_on_node_added)
	
	# Defer checkpoint loading to avoid scene tree conflicts
	call_deferred("_check_initial_checkpoint")
	
	# Init inventory system
	inventory_system = InventorySystem.new()
	add_child(inventory_system)
	
	# Connect Dialogic signals
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	print("GameManager initialized")

func _check_initial_checkpoint() -> void:
	if is_initial_load and has_checkpoint():
		print("Checkpoint found on project load, preparing to respawn")
		var checkpoint_info = checkpoint_data.get(current_checkpoint_id, {})
		if not checkpoint_info.is_empty():
			var checkpoint_stage = checkpoint_info.get("stage_path", "")
			if not checkpoint_stage.is_empty():
				should_respawn_at_checkpoint = true
				get_tree().change_scene_to_file(checkpoint_stage)
		is_initial_load = false
	else:
		is_initial_load = false

func _on_node_added(node: Node) -> void:
	if node is Player:
		player = node
		current_stage = get_tree().current_scene
		print("Player detected in scene: ", node.name)
		
		# Restore equipment
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
	
	print("Player equipment restored: Blade=%s, Hammer=%s" % [has_blade, has_hammer])

# =============================================================================
# STAGE & PORTAL SYSTEM
# =============================================================================
func change_stage(stage_path: String, _target_portal_name: String = "") -> void:
	target_portal_name = _target_portal_name
	should_respawn_at_checkpoint = false
	pending_teleport = not target_portal_name.is_empty()
	current_stage = null
	player = null
	is_initial_load = false
	get_tree().change_scene_to_file(stage_path)
	print("Changing stage to: ", stage_path)

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
	print("Changed to map: ", map_number)

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
	
	print("Checkpoint saved: ", checkpoint_id, " at ", player.global_position)
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

func player_died() -> void:
	should_respawn_at_checkpoint = true
	if current_stage != null:
		get_tree().reload_current_scene()
	else:
		if not current_checkpoint_id.is_empty():
			var checkpoint_info = checkpoint_data.get(current_checkpoint_id, {})
			var checkpoint_stage = checkpoint_info.get("stage_path", "")
			if not checkpoint_stage.is_empty():
				change_stage(checkpoint_stage, "")

func has_checkpoint() -> bool:
	return not current_checkpoint_id.is_empty()

func save_checkpoint_data() -> void:
	var save_data = {
		"current_checkpoint_id": current_checkpoint_id,
		"checkpoint_data": checkpoint_data
	}
	SaveSystem.save_checkpoint_data(save_data)
	print("Checkpoint data saved to file")

func load_checkpoint_data() -> void:
	var save_data = SaveSystem.load_checkpoint_data()
	if not save_data.is_empty():
		current_checkpoint_id = save_data.get("current_checkpoint_id", "")
		checkpoint_data = save_data.get("checkpoint_data", {})
		print("Checkpoint data loaded: ", current_checkpoint_id)

func clear_checkpoint_data() -> void:
	current_checkpoint_id = ""
	checkpoint_data.clear()
	SaveSystem.delete_save_file()
	print("All checkpoint data cleared")

# =============================================================================
# ITEM & WEAPON COLLECTION
# =============================================================================
func collected_blade() -> void:
	if not has_blade:
		has_blade = true
		print("Foxy đã nhận được thanh kiếm!")
		
		if player != null:
			if player.has_method("collect_powerup"):
				player.collect_powerup("blade")
			if player.has_method("collected_blade"):
				player.collected_blade()
		
		blade_collected.emit()

func collected_hammer() -> void:
	if not has_hammer:
		has_hammer = true
		print("Foxy đã nhận được cây búa!")
		
		if player != null and player.has_method("collected_hammer"):
			player.collected_hammer()

func collect_soul() -> void:
	souls_collected += 1

# =============================================================================
# ARTIFACT SYSTEM
# =============================================================================
func collect_artifact() -> void:
	"""Thu thập artifact không chỉ định ID (backward compatibility)"""
	artifacts_collected += 1
	artifact_collected.emit(artifacts_collected)
	_check_world_corruption()
	print("Di vật thu thập: %d/%d" % [artifacts_collected, total_artifacts])

func collect_artifact_with_id(artifact_id: int, artifact_name: String) -> void:
	"""Thu thập artifact với ID cụ thể (recommended)"""
	if artifact_id in collected_artifact_ids:
		push_warning("Artifact ID %d đã được thu thập rồi!" % artifact_id)
		return
	
	# Thêm vào danh sách
	collected_artifact_ids.append(artifact_id)
	
	# Tăng số lượng
	artifacts_collected += 1
	artifact_collected.emit(artifacts_collected)
	
	# Log
	print("✨ Đã thu thập: %s (ID: %d) - Tổng: %d/%d" % [artifact_name, artifact_id, artifacts_collected, total_artifacts])
	
	# Check world corruption
	_check_world_corruption()
	
	# Trigger special events
	_check_artifact_milestones(artifact_id)

func get_collected_artifact_ids() -> Array[int]:
	"""Trả về danh sách ID artifacts đã thu thập"""
	return collected_artifact_ids

func has_artifact(artifact_id: int) -> bool:
	"""Kiểm tra đã có artifact này chưa"""
	return artifact_id in collected_artifact_ids

func _check_artifact_milestones(artifact_id: int) -> void:
	"""Kiểm tra các mốc quan trọng khi thu thập artifact"""
	match artifacts_collected:
		1:
			set_story_flag("first_artifact_collected", true)
		3:
			set_story_flag("world_corruption_started", true)
		5:
			set_story_flag("npcs_fear_player", true)
		7:
			set_story_flag("all_artifacts_collected", true)

# =============================================================================
# STORY FLAG SYSTEM
# =============================================================================
func set_story_flag(flag_name: String, value: bool = true) -> void:
	if flag_name in story_flags:
		story_flags[flag_name] = value
		story_flag_changed.emit(flag_name, value)
		print("Story flag set: %s = %s" % [flag_name, value])
	else:
		# Cho phép thêm flag mới dynamically
		story_flags[flag_name] = value
		print("New story flag added: %s = %s" % [flag_name, value])

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
		"collected_hammer":
			collected_hammer()
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
		"world_start_changing":
			_trigger_world_decay_phase_1()
		"world_corruption_complete":
			_trigger_world_decay_phase_2()
		_:
			print("Dialogic signal không xác định: " + argument)

# =============================================================================
# WORLD CORRUPTION SYSTEM
# =============================================================================
func _check_world_corruption() -> void:
	if artifacts_collected >= 3 and current_map >= 6:
		_trigger_world_decay()

func _trigger_world_decay() -> void:
	print("⚠️ Thế giới bắt đầu suy tàn... (Artifacts: %d)" % artifacts_collected)
	# Có thể gọi WorldEnvironment để thay đổi
	_apply_corruption_visual(artifacts_collected)

func _trigger_world_decay_phase_1() -> void:
	print("🌑 World Decay Phase 1: Subtle changes")
	# Áp dụng thay đổi nhẹ

func _trigger_world_decay_phase_2() -> void:
	print("🌑🌑 World Decay Phase 2: Major corruption")
	# Áp dụng thay đổi mạnh

func _apply_corruption_visual(artifact_count: int) -> void:
	"""Áp dụng hiệu ứng visual dựa trên số artifact"""
	# Bạn có thể gọi đến WorldManager hoặc thay đổi trực tiếp
	# Ví dụ: brightness giảm dần theo artifact
	var corruption_level = float(artifact_count) / float(total_artifacts)
	print("Corruption level: %.1f%%" % (corruption_level * 100))

# =============================================================================
# PLAYER CONTROL
# =============================================================================
func set_player_can_move(can_move: bool) -> void:
	if player == null:
		push_warning("GameManager: Player chưa được set!")
		return
	
	if player.has_method("set_can_move"):
		player.set_can_move(can_move)
	else:
		player.set_physics_process(can_move)
		player.set_process_input(can_move)

func freeze_player() -> void:
	if player == null:
		return
	player.velocity = Vector2.ZERO
	set_player_can_move(false)

func unfreeze_player() -> void:
	set_player_can_move(true)

# =============================================================================
# SAVE/LOAD FULL GAME STATE
# =============================================================================
func save_game() -> void:
	var save_data = {
		"has_blade": has_blade,
		"has_hammer": has_hammer,
		"artifacts_collected": artifacts_collected,
		"collected_artifact_ids": collected_artifact_ids,
		"souls_collected": souls_collected,
		"current_map": current_map,
		"story_flags": story_flags,
		"enemies_killed": enemies_killed,
		"npcs_helped": npcs_helped,
		"warnings_ignored": warnings_ignored
	}
	
	if player != null:
		save_data["player_position"] = {
			"x": player.global_position.x,
			"y": player.global_position.y
		}
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("✅ Game đã được lưu!")
	else:
		push_error("❌ Không thể tạo file save!")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		print("⚠️ Không tìm thấy file save!")
		return
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if not file:
		push_error("❌ Không thể mở file save!")
		return
	
	var save_data = file.get_var()
	file.close()
	
	has_blade = save_data.get("has_blade", false)
	has_hammer = save_data.get("has_hammer", false)
	artifacts_collected = save_data.get("artifacts_collected", 0)
	collected_artifact_ids = save_data.get("collected_artifact_ids", [])
	souls_collected = save_data.get("souls_collected", 0)
	current_map = save_data.get("current_map", 1)
	story_flags = save_data.get("story_flags", {})
	enemies_killed = save_data.get("enemies_killed", 0)
	npcs_helped = save_data.get("npcs_helped", 0)
	warnings_ignored = save_data.get("warnings_ignored", 0)
	
	if player != null and save_data.has("player_position"):
		var pos = save_data["player_position"]
		player.global_position = Vector2(pos["x"], pos["y"])
	
	if has_blade and player != null and player.has_method("collected_blade"):
		player.collected_blade()
	if has_hammer and player != null and player.has_method("collected_hammer"):
		player.collected_hammer()
	
	print("✅ Game đã được load!")

# =============================================================================
# DEBUG & RESET FUNCTIONS
# =============================================================================
func reset_game() -> void:
	has_blade = false
	has_hammer = false
	artifacts_collected = 0
	collected_artifact_ids.clear()
	souls_collected = 0
	current_map = 1
	enemies_killed = 0
	npcs_helped = 0
	warnings_ignored = 0
	
	for key in story_flags.keys():
		story_flags[key] = false
	
	print("🔄 Game state đã được reset!")

func print_debug_info() -> void:
	print("\n" + "=".repeat(50))
	print("GAME MANAGER DEBUG INFO")
	print("=".repeat(50))
	print("📍 PLAYER")
	print("  - Reference: ", "Valid ✓" if player != null else "NULL ✗")
	if player != null:
		print("  - Position: ", player.global_position)
	print("\n🗡️ WEAPONS")
	print("  - Blade: ", "✓" if has_blade else "✗")
	print("  - Hammer: ", "✓" if has_hammer else "✗")
	print("\n🏺 ARTIFACTS")
	print("  - Collected: %d/%d (%.1f%%)" % [artifacts_collected, total_artifacts, get_artifact_percentage()])
	print("  - IDs: ", collected_artifact_ids)
	print("\n🗺️ PROGRESS")
	print("  - Current Map: ", current_map)
	print("  - Souls: ", souls_collected)
	print("  - Enemies Killed: ", enemies_killed)
	print("  - NPCs Helped: ", npcs_helped)
	print("  - Warnings Ignored: ", warnings_ignored)
	print("\n🚩 STORY FLAGS")
	for flag in story_flags:
		if story_flags[flag]:
			print("  - %s: ✓" % flag)
	print("\n💾 CHECKPOINT")
	print("  - Current: ", current_checkpoint_id if not current_checkpoint_id.is_empty() else "None")
	print("  - Has Checkpoint: ", "✓" if has_checkpoint() else "✗")
	print("=".repeat(50) + "\n")
