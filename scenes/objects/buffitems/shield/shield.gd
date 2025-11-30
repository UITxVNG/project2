extends InteractiveArea2D

func _ready() -> void:
	interaction_available.connect(_on_interaction_available)
	super._ready()
	
func shield():
	GameManager.player.collect_powerup("shield")
	print("You have shield for 10 sec!")
	queue_free()
	
func _on_interaction_available() -> void:
	shield()
