class_name Player
extends BaseCharacter

## Player character class that handles movement, combat, and state management
var is_invulnerable: bool = false
@export var has_blade: bool = false
@onready var bullet_factory := $Direction/BulletFactory
func _ready() -> void:
	super._ready()
	fsm = FSM.new(self, $States, $States/Idle)
	$HurtArea2D.hurt.connect(_on_hurt_area_2d_hurt)
	if has_blade:
		collected_blade()
	GameManager.player = self
		
func save_state() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y]
	}

func load_state(data: Dictionary) -> void:
	"""Load player state from checkpoint data"""
	if data.has("position"):
		var pos_array = data["position"]
		global_position = Vector2(pos_array[0], pos_array[1])
			
func can_attack() -> bool:
	return has_blade

func collected_blade() -> void:
	has_blade = true
	set_animated_sprite($Direction/BladeAnimatedSprite2D)
			
func _on_hurt_area_2d_hurt(_direction: Variant, _damage: Variant) -> void:
	fsm.current_state.take_damage(_damage)
	
func throw_blade(speed: float) -> void:
	var blade = bullet_factory.create() as RigidBody2D
	blade.global_position = $Direction/FirePoint.global_position
	var impulse = Vector2(direction * speed, 0)
	blade.apply_impulse(impulse)

func play_jump_sound() -> void:
	$Jump.play()
