extends Node

## Save system for persistent checkpoint data

const SAVE_FILE = "user://checkpoint_save.dat"

# Save checkpoint data to file
func save_checkpoint_data(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		file.close()
		print("Checkpoint data saved successfully")
	else:
		print("Error: Could not open save file for writing")

# Load checkpoint data from file
func load_checkpoint_data() -> Dictionary:
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
	return FileAccess.file_exists(SAVE_FILE)

# Delete save file
func delete_save_file() -> void:
	if has_save_file():
		DirAccess.remove_absolute(SAVE_FILE)
		print("Save file deleted")
