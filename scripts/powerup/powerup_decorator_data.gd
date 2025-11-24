class_name PowerupDecoratorData
extends Resource

## Data resource for power-up decorators
@export_group("Basic Info")
@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D

@export_group("Decorator Settings")
# Script of decorator
@export var decorator_script: Script  = GenericPowerupDecorator
@export var priority: int = 0
# Duration of the power-up in seconds, -1 = permanent, 0 = instant
@export var duration: float = -1.0

@export_group("Stat Modifiers")
# Speed multiplier
@export var speed_multiplier: float = 1.0
# Jump multiplier
@export var jump_multiplier: float = 1.0
# Damage multiplier
@export var damage_multiplier: float = 1.0
# Health bonus
@export var health_bonus: int = 0

@export_group("Abilities")
# Grants blade attack
@export var grants_blade_attack: bool = false

@export_group("Visual Settings")
# Sprite override for decorator, get child of Direction node
@export var sprite_override: String = ""
@export var color_modulate: Color = Color.WHITE

@export_group("Stacking Rules")
# IDs of power-ups that conflict with this power-up
@export var conflicts_with: Array[String] = []
# IDs of power-ups that replace this power-up
@export var replaces: Array[String] = []
# Can stack with other power-ups
@export var can_stack: bool = true

# Factory method to create decorator instance
func create_decorator(player: Player) -> PowerupDecorator:
	if not decorator_script:
		return null
	
	var decorator = decorator_script.new(player, self)
	return decorator
