extends Area2D
class_name HurtArea2D

# signal when hurt
signal hurt(direction: Vector2, damage: float)

# called when take damage
func take_damage(direction: Vector2, damage: float):
	hurt.emit(direction, damage)
