extends MarginContainer

@onready var coin_label = $VBoxContainer/HBoxContainer2/CoinLabel
@onready var key_label = $VBoxContainer/HBoxContainer2/KeyLabel
@onready var health_bar = $VBoxContainer/HBoxContainer/TextureProgressBar

func _ready() -> void:
	$VBoxContainer/HBoxContainer/SettingsTextureButton.pressed.connect(_on_settings_texture_button_pressed)
	health_bar.max_value = 3 
	pass

func _process(delta: float) -> void:
	coin_label.text = " X %s" % GameManager.inventory_system.get_gold()
	key_label.text = " X %s" % GameManager.inventory_system.get_keys()
	health_bar.value = GameManager.player.health

func _on_settings_texture_button_pressed() -> void:
	var popup_settings = load("res://scenes/screens/game_screen/settings_popup.tscn").instantiate()
	get_parent().add_child(popup_settings)
	pass # Replace with function body.
	
