extends InteractiveArea2D

var collected = false

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	interaction_available.connect(_on_interaction_available)
	super._ready()
	
func collect_coin():
	if !collected:
		collected = true
		GameManager.inventory_system.add_key()
		$Coin.play()
	$AnimatedSprite2D.play("collected")
	await $AnimatedSprite2D.animation_finished
	queue_free()
	
func _on_interaction_available() -> void:
	collect_coin()
