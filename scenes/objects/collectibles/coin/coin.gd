extends InteractiveArea2D

@export var coin_amount = 1
var collected = false

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	interaction_available.connect(_on_interaction_available)
	super._ready()
	
func collect_coin():
	if !collected:
		collected = true
		GameManager.inventory_system.add_coin(coin_amount)
		$Coin.play()
	$AnimatedSprite2D.play("collected")
	await $AnimatedSprite2D.animation_finished
	queue_free()
	
func _on_interaction_available() -> void:
	collect_coin()
