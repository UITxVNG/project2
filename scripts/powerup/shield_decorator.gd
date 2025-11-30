class_name ShieldDecorator
extends PowerupDecorator

var hits := 1

func modify_damage_taken(dmg: int) -> int:
	if hits > 0:
		hits -= 1
		# Shield breaks → expire decorator
		time_remaining = 0
		print("[Shield] Damage blocked!")
		return 0

	return dmg
