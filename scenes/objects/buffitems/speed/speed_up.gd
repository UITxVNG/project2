extends InteractiveArea2D

func _ready() -> void:
	interaction_available.connect(_on_interaction_available)
	super._ready()
	
func speed_up():
	GameManager.player.collect_powerup("speed_up")
	print("You have speed up for 5 sec!")
	queue_free()
	
func _on_interaction_available() -> void:
	speed_up()
