extends InteractiveArea2D

func _ready() -> void:
	interaction_available.connect(_on_interaction_available)
	super._ready()
	
func hammer():
	GameManager.player.collect_powerup("hammer_summon")
	print("You have thor power")
	queue_free()
	
func _on_interaction_available() -> void:
	hammer()
