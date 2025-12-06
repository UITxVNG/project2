extends Area2D

func _ready():
	connect("area_entered", _on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	print("HURTBOX TRIGGERED:", area)

	# ===== TÌM PLAYER =====
	var node = area
	var player: Player = null

	while node:
		if node is Player:
			player = node
			break
		node = node.get_parent()

	if player == null:
		print("NO PLAYER FOUND")
		return

	print("FOUND PLAYER:", player)

	# ===== TÌM ROCK (đi lên parent từ HurtArea2D) =====
	var rnode = self
	while rnode and not (rnode is Rock):
		rnode = rnode.get_parent()

	if rnode == null:
		print("NO ROCK FOUND")
		return

	print("FOUND ROCK:", rnode)

	# ===== CHECK STATE =====
	if player.fsm.current_state == player.fsm.states.crush:
		print("CALLING CRUSH BREAK")
		rnode.crush_break()
	else:
		print("NOT CRUSH STATE")
