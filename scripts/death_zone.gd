extends Area2D

## Death zone that instantly kills the player when they fall off the map

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body is Player:
		var player = body as Player
		# Set health to 0 and force dead state
		player.health = 0
		
		# Find and trigger dead state
		if player.fsm and player.fsm.states.has("dead"):
			player.fsm.change_state(player.fsm.states["dead"])
