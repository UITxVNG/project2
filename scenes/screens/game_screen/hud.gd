extends MarginContainer

@onready var coin_label = $VBoxContainer/HBoxContainer2/CoinLabel
@onready var key_label = $VBoxContainer/HBoxContainer2/KeyLabel

func _ready() -> void:
	$VBoxContainer/HBoxContainer/SettingsTextureButton.pressed.connect(_on_settings_texture_button_pressed)
	pass

func _process(delta: float) -> void:
	coin_label.text = " X %s" % GameManager.inventory_system.get_gold()
	key_label.text = " X %s" % GameManager.inventory_system.get_keys()

func _on_settings_texture_button_pressed() -> void:
	var popup_settings = load("res://scenes/screens/game_screen/settings_popup.tscn").instantiate()
	get_parent().add_child(popup_settings)
	pass # Replace with function body.
