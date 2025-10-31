extends MarginContainer

func _ready() -> void:
	$HBoxContainer/SettingsTextureButton.pressed.connect(_on_settings_texture_button_pressed)
	pass


func _on_settings_texture_button_pressed() -> void:
	var popup_settings = load("res://scenes/screens/game_screen/settings_popup.tscn").instantiate()
	get_parent().add_child(popup_settings)
	pass # Replace with function body.
