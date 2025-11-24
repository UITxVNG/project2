class_name PowerupDecorator
extends RefCounted

## Base decorator class using data-driven approach
var player: Player
var data = null
var next_decorator: PowerupDecorator = null

# Runtime state
var time_remaining: float
var is_active: bool = false

func _init(target_player: Player, decorator_data: PowerupDecoratorData):
	player = target_player
	data = decorator_data
	time_remaining = data.duration

# Delegate methods with data-driven modifiers
func get_movement_speed() -> float:
	var base_speed = _get_next_speed()
	return base_speed * data.speed_multiplier

func get_jump_speed() -> float:
	var base_speed = _get_next_jump()
	return base_speed * data.jump_multiplier

func get_attack_damage() -> int:
	var base_damage = _get_next_damage()
	return int(base_damage * data.damage_multiplier)

func get_max_health() -> int:
	var base_health = _get_next_health()
	return base_health + data.health_bonus

func get_size_multiplier() -> float:
	var base_size = _get_next_size()
	return base_size * data.size_multiplier

# Ability checks from data
func can_blade_attack() -> bool:
	return data.grants_blade_attack or _get_next_blade_attack()

# Visual properties from data
func get_sprite_override() -> String:
	if not data.sprite_override.is_empty():
		return data.sprite_override
	return _get_next_sprite()

func get_color_modulate() -> Color:
	if data.color_modulate != Color.WHITE:
		return data.color_modulate
	return _get_next_color()

# Helper methods to get from chain
func _get_next_speed() -> float:
	if next_decorator:
		return next_decorator.get_movement_speed()
	return player.movement_speed

func _get_next_jump() -> float:
	if next_decorator:
		return next_decorator.get_jump_speed()
	return player.jump_speed

func _get_next_damage() -> int:
	if next_decorator:
		return next_decorator.get_attack_damage()
	return player.attack_damage

func _get_next_health() -> int:
	if next_decorator:
		return next_decorator.get_max_health()
	return player.max_health

func _get_next_size() -> float:
	if next_decorator:
		return next_decorator.get_size_multiplier()
	return 1.0

func _get_next_blade_attack() -> bool:
	if next_decorator:
		return next_decorator.can_blade_attack()
	return false

func _get_next_sprite() -> String:
	if next_decorator:
		return next_decorator.get_sprite_override()
	return ""

func _get_next_color() -> Color:
	if next_decorator:
		return next_decorator.get_color_modulate()
	return Color.WHITE

func _get_next_animation() -> String:
	if next_decorator:
		return next_decorator.get_animation_override()
	return ""

# Lifecycle methods
func on_apply():
	is_active = true
	_apply_visual_changes()

func on_remove():
	is_active = false
	_remove_visual_changes()

func update(delta: float):
	if data.duration > 0:
		time_remaining -= delta
		if time_remaining <= 0:
			return true  # Expired decorator
	
	if next_decorator:
		if next_decorator.update(delta):
			# Next decorator expired, remove it from chain
			pass
	
	return false

func _apply_visual_changes():
	# Apply sprite
	if not data.sprite_override.is_empty():
		var sprite_node = player.get_node_or_null("Direction/" + data.sprite_override)
		if sprite_node:
			player.set_animated_sprite(sprite_node)
	
	# Apply color
	if data.color_modulate != Color.WHITE:
		player.modulate = data.color_modulate

func _remove_visual_changes():
	
	# Revert sprite
	if not data.sprite_override.is_empty():
		player.set_animated_sprite(player.get_node("Direction/AnimatedSprite2D"))
	
	# Revert color
	if data.color_modulate != Color.WHITE:
		player.modulate = Color.WHITE
