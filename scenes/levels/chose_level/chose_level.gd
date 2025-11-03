extends Control

const LEVEL_PATH_FORMAT := "res://scenes/levels/level_%d/stage_%d.tscn"

# Called when the scene starts
func _ready() -> void:
	# Connect all button signals automatically (based on their names)
	for button in $GridContainer.get_children():
		if button is Button:
			var level_num = int(button.name.replace("Level", ""))
			button.connect("pressed", Callable(self, "_on_level_pressed").bind(level_num))


func _on_level_pressed(level_num: int) -> void:
	var level_path = LEVEL_PATH_FORMAT % [level_num, level_num]

	if ResourceLoader.exists(level_path):
		print("Loading:", level_path)
		get_tree().change_scene_to_file(level_path)
	else:
		push_error("⚠️ Level not found: %s" % level_path)
