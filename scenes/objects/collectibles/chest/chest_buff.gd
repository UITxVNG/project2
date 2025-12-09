extends InteractiveArea2D

@export var buff_scene : PackedScene

var is_opened: bool = false

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	interacted.connect(_on_interacted)
	
func _on_interacted():
	print(name, "was interacted")
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
	spawn_buff()
	
func spawn_buff():
	if buff_scene == null:
		print("No buff scene assigned!")
		return
	
	var buff_instance = buff_scene.instantiate()
	get_parent().add_child(buff_instance)
	
	buff_instance.global_position = global_position + Vector2(0, -20)
	print("Chest opened! Buff spawned.")
