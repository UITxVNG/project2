class_name Rock
extends EnemyCharacter

signal rock_broken

func _ready() -> void:
	# Không cần patrol, detect, raycast
	front_ray_cast = null
	down_ray_cast = null
	detect_player_area = null

	# Setup FSM
	fsm = FSM.new(self, $States, $States/Idle)

	super._ready()


# Rock KHÔNG đi tuần tra, KHÔNG rớt, KHÔNG phát hiện player
func try_patrol_turn(_delta: float):
	pass


# Rock KHÔNG bị damage bình thường
func _take_damage_from_dir(_damage: int):
	# Chỉ hammer crush mới phá được → không làm gì
	pass


# Hàm này được player gọi khi dùng crush trúng vào rock
func crush_break():
	fsm.change_state(fsm.states.broken)
