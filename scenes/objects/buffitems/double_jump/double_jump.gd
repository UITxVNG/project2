extends InteractiveArea2D

func _ready() -> void:
	interaction_available.connect(_on_interaction_available)
	super._ready()
	
func shield():
	GameManager.player.collect_powerup("double_jump")
	print("You have double jump for 10 sec!")
	queue_free()
	
func _on_interaction_available() -> void:
	shield()
