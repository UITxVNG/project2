extends PowerupDecorator

func on_apply():
	super.on_apply()
	player.max_jumps += 1

func on_remove():
	super.on_remove()
	player.max_jumps -= 1
