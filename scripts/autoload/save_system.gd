extends Node

## Save system for persistent checkpoint data

const SAVE_FILE = "user://checkpoint_save.dat"

# In-memory storage for editor testing (not persisted)
var _temp_data: Dictionary = {}

func _is_editor_playtest() -> bool:
	return OS.has_feature("editor")

# Save checkpoint data to file
func save_checkpoint_data(data: Dictionary) -> void:
	if _is_editor_playtest():
		# Editor mode: only keep in memory, don't write to file
		_temp_data = data.duplicate(true)
		print("[DEBUG] Checkpoint saved to memory (not persisted)")
		return
	
	# Release mode: save to file
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		print("Checkpoint data saved successfully")
	else:
		print("Error: Could not open save file for writing")

# Load checkpoint data from file
func load_checkpoint_data() -> Dictionary:
	if _is_editor_playtest():
		# Editor mode: return memory data (empty if fresh playtest)
		print("[DEBUG] Loading from memory (temp data)")
		return _temp_data.duplicate(true)
	
	# Release mode: load from file
	if not has_save_file():
		print("No save file found")
		return {}
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			if data is Dictionary:
				print("Checkpoint data loaded successfully")
				return data
			else:
				print("Error: Loaded data is not a Dictionary")
				return {}
		else:
			print("Error parsing JSON: ", json.get_error_message())
			return {}
	else:
		print("Error: Could not open save file for reading")
		return {}

# Check if save file exists
func has_save_file() -> bool:
	if _is_editor_playtest():
		return not _temp_data.is_empty()
	return FileAccess.file_exists(SAVE_FILE)

# Delete save file
func delete_save_file() -> void:
	if _is_editor_playtest():
		_temp_data.clear()
		print("[DEBUG] Temp save data cleared")
		return
	
	if has_save_file():
		DirAccess.remove_absolute(SAVE_FILE)
		print("Save file deleted")
