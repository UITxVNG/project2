class_name PowerupDatabase
extends Resource

## Database that contains all powerup data
@export var powerups: Array[PowerupDecoratorData] = []

var _powerup_map: Dictionary = {}

func _init():
	_rebuild_map()

func _rebuild_map():
	_powerup_map.clear()
	for powerup in powerups:
		if not powerup.id.is_empty():
			_powerup_map[powerup.id] = powerup

func get_powerup(id: String) -> PowerupDecoratorData:
	if _powerup_map.is_empty():
		_rebuild_map()
	return _powerup_map.get(id, null)

func get_all_powerups() -> Array[PowerupDecoratorData]:
	return powerups.duplicate()

func has_powerup(id: String) -> bool:
	return _powerup_map.has(id)
