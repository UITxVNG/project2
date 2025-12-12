extends MarginContainer

@onready var coin_label = $VBoxContainer/HBoxContainer2/CoinLabel
@onready var key_label = $VBoxContainer/HBoxContainer2/KeyLabel
@onready var health_potion = $VBoxContainer/HBoxContainer2/HealthPotionLabel
@onready var mana_potion = $VBoxContainer/HBoxContainer2/ManaPotionLabel
@onready var health_bar = $VBoxContainer/HBoxContainer/TextureProgressBar
@onready var mana_bar = $VBoxContainer/HBoxContainer/TextureProgressBar2
func _ready() -> void:
	$VBoxContainer/HBoxContainer/SettingsTextureButton.pressed.connect(_on_settings_texture_button_pressed)
	health_bar.max_value = 10 
	mana_bar.max_value = 100
	pass

func _process(delta: float) -> void:
	coin_label.text = " X %s" % GameManager.inventory_system.get_gold()
	key_label.text = " X %s" % GameManager.inventory_system.get_keys()
	health_potion.text = " X %s" % GameManager.inventory_system.get_health_potion()
	mana_potion.text = " X %s" % GameManager.inventory_system.get_mana_potion()
	health_bar.value = GameManager.player.health
	mana_bar.value = GameManager.player.mana
func _on_settings_texture_button_pressed() -> void:
	var popup_settings = load("res://scenes/screens/game_screen/settings_popup.tscn").instantiate()
	get_parent().add_child(popup_settings)
	pass # Replace with function body.
	
