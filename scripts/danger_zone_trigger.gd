extends Area2D

## Khu vực trigger để kích hoạt nước dâng khi player bước vào

@export var rising_water_path: NodePath  # Path tới node RisingWater

var has_triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if has_triggered:
		return
	
	if body.is_in_group("player"):
		has_triggered = true
		
		# Kích hoạt nước dâng
		var rising_water = get_node_or_null(rising_water_path)
		if rising_water and rising_water.has_method("start_rising"):
			rising_water.start_rising()
			print("Danger zone triggered! Water is rising...")
