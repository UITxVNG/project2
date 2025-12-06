extends PowerupDecorator

func on_apply():
	player.has_hammer = true
	player.unlock_hammer = true
	player.collected_hammer()

func on_remove():
	player.has_hammer = false
	# Trở lại sprite mặc định
	var idle_sprite = player.get_node("Direction/IdleAnimatedSprite2D")
	player.set_animated_sprite(idle_sprite)
