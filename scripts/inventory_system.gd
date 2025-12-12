extends Node
class_name InvetorySystem

signal coin_changed(new_amount: int)
signal item_collected(item_type: String, amount: int)
signal potion_changed(health_potions: int, mana_potions: int)

var coins: int = 0
var keys: int = 0
var health_potions: int = 3
var mana_potions: int = 3

func _ready() -> void:
	pass
	
func add_coin(amount: int) -> void:
	coins += amount
	coin_changed.emit(coins)
	item_collected.emit("coin", amount)
	print("Collected ", amount, " coins. Total: ", coins)
	
func add_key(_amount: int = 1) -> void:
	#TODO: Implement key collection
	keys += _amount
	print("Collected 1 key. Total: ", keys)
	pass

func add_health_potion(amount: int = 1) -> void:
	health_potions += amount
	item_collected.emit("health_potion", amount)
	potion_changed.emit(health_potions, mana_potions)
	print("Collected ", amount, " health potion(s). Total: ", health_potions)

func use_health_potion() -> bool:
	if health_potions > 0:
		health_potions -= 1
		potion_changed.emit(health_potions, mana_potions)
		print("Used 1 health potion. Remaining: ", health_potions)
		return true
	return false
func add_mana_potion(amount: int = 1) -> void:
	mana_potions += amount
	item_collected.emit("mana_potion", amount)
	potion_changed.emit(health_potions, mana_potions)
	print("Collected ", amount, " mana potion(s). Total: ", mana_potions)

func use_mana_potion() -> bool:
	if mana_potions > 0:
		mana_potions -= 1
		potion_changed.emit(health_potions, mana_potions)
		print("Used 1 mana potion. Remaining: ", mana_potions)
		return true
	return false

func get_mana_potion() -> int:
	return mana_potions
func get_health_potion() -> int:
	return health_potions

func use_key() -> bool:
	#TODO: Implement key usage
	keys -= 1
	print("You used 1 key. Total: ", keys)
	return false

func has_key() -> bool:
	return keys > 0	

func get_gold() -> int:
	return coins

func get_keys() -> int:
	return keys
