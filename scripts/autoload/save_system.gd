extends Node

## Save system for persistent checkpoint data

const SAVE_FILE = "user://checkpoint_save.dat"
const EDITOR_SAVE_FILE = "user://checkpoint_save_editor.dat"


# Clear save data when closing debug window in editor
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if OS.has_feature("editor"):
			delete_save_file()
			print("[DEBUG] Save file cleared on editor quit")

func _get_save_path() -> String:
	if OS.has_feature("editor"):
		return EDITOR_SAVE_FILE
	return SAVE_FILE

# Save checkpoint data to file (always persisted, even in editor)
func save_checkpoint_data(data: Dictionary) -> void:
	var save_path = _get_save_path()
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		file.close()
		print("[DEBUG] Checkpoint saved to: ", save_path)
	else:
		print("Error: Could not open save file for writing: ", save_path)

# Load checkpoint data from file
func load_checkpoint_data() -> Dictionary:
	var save_path = _get_save_path()
	
	if not FileAccess.file_exists(save_path):
		print("[DEBUG] No save file found at: ", save_path)
		return {}
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			if data is Dictionary:
				print("[DEBUG] Checkpoint loaded from: ", save_path)
				print("[DEBUG] Loaded checkpoint_id: ", data.get("current_checkpoint_id", "NONE"))
				return data
			else:
				print("Error: Loaded data is not a Dictionary")
				return {}
		else:
			print("Error parsing JSON: ", json.get_error_message())
			return {}
	else:
		print("Error: Could not open save file for reading: ", save_path)
		return {}

# Check if save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(_get_save_path())

# Delete save file
func delete_save_file() -> void:
	var save_path = _get_save_path()
	if has_save_file():
		DirAccess.remove_absolute(save_path)
		print("[DEBUG] Save file deleted: ", save_path)
