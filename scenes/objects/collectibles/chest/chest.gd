extends InteractiveArea2D

@export var coin_reward: int = 5

var is_opened: bool = false

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	interacted.connect(_on_interacted)
	
func _on_interacted():
	attemp_open_chest()
	
func attemp_open_chest():
	if is_opened:
		return
	if GameManager.inventory_system.has_key():
		open_chest()
		
func open_chest():
	if is_opened:
		return
	is_opened = true
	GameManager.inventory_system.use_key()
	animated_sprite.play("open")
	await animated_sprite.animation_finished
	GameManager.inventory_system.add_coin(coin_reward)
	print("Chest opened! You received ", coin_reward, " coin!")
	
