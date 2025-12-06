# game_manager.gd
extends Node

const InventorySystem = preload("res://scripts/inventory_system.gd")
# === Reference đến Player ===
var player: CharacterBody2D = null  # ← THÊM DÒNG NÀY
var inventory_system: InventorySystem = null

# === Trạng thái vật phẩm ===
var has_blade: bool = false
var artifacts_collected: int = 0
var total_artifacts: int = 7
var souls_collected: int = 0

# === Trạng thái cốt truyện ===
var current_map: int = 1
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

# === Checkpoint System ===
var current_checkpoint_id: String = ""
var last_checkpoint_position: Vector2 = Vector2.ZERO





func _ready() -> void:
	inventory_system = InventorySystem.new()
	# Kết nối với Dialogic signals
	Dialogic.signal_event.connect(_on_dialogic_signal)

# === Hàm quản lý vật phẩm ===
func collected_blade() -> void:
	if not has_blade:
		has_blade = true
		GameManager.player.collect_powerup("blade")
		print("Foxy đã nhận được thanh kiếm!")
		
		# Gọi hàm trong player để trang bị kiếm
		if player != null and player.has_method("collected_blade"):
			player.collected_blade()
		
		blade_collected.emit()


func collect_artifact() -> void:
	artifacts_collected += 1
	artifact_collected.emit(artifacts_collected)
	
	# Kích hoạt thay đổi môi trường dựa trên số artifact
	_check_world_corruption()
	
	print("Di vật thu thập: %d/%d" % [artifacts_collected, total_artifacts])

func collect_soul() -> void:
	souls_collected += 1

# === Hàm quản lý cốt truyện ===
func set_story_flag(flag_name: String, value: bool = true) -> void:
	if flag_name in story_flags:
		story_flags[flag_name] = value
		story_flag_changed.emit(flag_name, value)
		print("Story flag set: %s = %s" % [flag_name, value])

func get_story_flag(flag_name: String) -> bool:
	return story_flags.get(flag_name, false)

func change_map(map_number: int) -> void:
	current_map = map_number
	map_changed.emit(map_number)

# === Kiểm tra điều kiện ending ===
func get_artifact_percentage() -> float:
	return (float(artifacts_collected) / float(total_artifacts)) * 100.0

func should_get_bad_ending() -> bool:
	return get_artifact_percentage() >= 70.0 and story_flags.get("final_choice_made", false)

func should_get_good_ending() -> bool:
	var percentage = get_artifact_percentage()
	return percentage >= 30.0 and percentage < 70.0

func should_get_secret_ending() -> bool:
	return get_artifact_percentage() < 29.0

# === Xử lý sự kiện từ Dialogic ===
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

# === Kiểm tra độ tham lam và thay đổi thế giới ===
func _check_world_corruption() -> void:
	# Map 6 trở đi: thế giới bắt đầu suy tàn
	if artifacts_collected >= 3 and current_map >= 6:
		_trigger_world_decay()

func _trigger_world_decay() -> void:
	# Thay đổi màu sắc, weather, âm nhạc
	print("Thế giới bắt đầu suy tàn...")
	# Có thể gọi WorldEnvironment để thay đổi

# === Player Control (Tương thích với Player class hiện tại) ===
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

# === Save/Load (tùy chọn) ===
func save_game() -> void:
	var save_data = {
		"has_blade": has_blade,
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
	
	print("Game đã được load!")

# === Debug Functions ===
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
	print("========================\n")

func save_checkpoint(checkpoint_id: String) -> void:
	current_checkpoint_id = checkpoint_id

	# Nếu có player, lưu vị trí hiện tại của player
	if player != null:
		last_checkpoint_position = player.global_position

	print("Checkpoint saved:", checkpoint_id)


func save_checkpoint_data() -> void:
	var data = {
		"current_checkpoint_id": current_checkpoint_id,
		"last_checkpoint_position": {
			"x": last_checkpoint_position.x,
			"y": last_checkpoint_position.y
		}
	}

	var file = FileAccess.open("user://checkpoint.save", FileAccess.WRITE)
	if file:
		file.store_var(data)
		file.close()
