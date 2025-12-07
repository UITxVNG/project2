class_name Rock
extends EnemyCharacter

signal rock_broken

func _ready() -> void:
	front_ray_cast = null
	down_ray_cast = null
	detect_player_area = null

	fsm = FSM.new(self, $States, $States/Idle)
	super._ready()

func try_patrol_turn(_delta: float):
	pass
func take_damage(_a, _b = null) -> void:
	# Rock không nhận damage
	pass


func crush_break():
	fsm.change_state(fsm.states.broken)
