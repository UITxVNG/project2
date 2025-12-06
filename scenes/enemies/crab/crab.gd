extends EnemyCharacter

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	super._ready()


func take_damage(a, b = null) -> void:
	var hit_dir: Vector2
	var damage: float
	if typeof(a) == TYPE_VECTOR2 and b != null:
		hit_dir = a
		damage = float(b)
	else:
		hit_dir = Vector2.ZERO
		damage = float(a)

	health -= damage

	if health <= 0:
		_die()



func _die() -> void:
	queue_free()
