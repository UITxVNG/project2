extends EnemyCharacter

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Idle)
	super._ready()
	get_node("Direction/HitArea2D/CollisionShape2D").disabled = true
