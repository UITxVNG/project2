class_name Player
extends BaseCharacter

## Player character class that handles movement, combat, and state management
var is_invulnerable: bool = false
var invulnerable_timer: float = 0.0
var flicker_tween: Tween
@export var has_blade: bool = false
@onready var bullet_factory := $Direction/BulletFactory
var has_double_jump_buff: bool = false
var jump_count: int = 0
var max_jumps: int = 1
var double_jump_buff_timer: float = 0.0
var has_shield_buff: bool = false
var shield_buff_timer: float = 0.0
var shield_hits: int = 0   # số hit mà shield chặn được (1 hit)

@export var jump_smoke_scene: PackedScene
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



func apply_double_jump_buff(duration: float):
	has_double_jump_buff = true
	max_jumps = 2
	double_jump_buff_timer = duration
	print("Double jump buff activated for ", duration, " seconds")

func remove_double_jump_buff():
	has_double_jump_buff = false
	max_jumps = 1
	print("Double jump buff expired")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# handle invulnerability countdown
	if is_invulnerable:
		invulnerable_timer -= delta
		if invulnerable_timer <= 0:
			end_invulnerability()
	# --- HANDLE DOUBLE JUMP BUFF COUNTDOWN ---
	if has_double_jump_buff:
		double_jump_buff_timer -= delta
		if double_jump_buff_timer <= 0:
			remove_double_jump_buff()
	
	# --- RESET JUMP WHEN ON FLOOR ---
	if is_on_floor() and velocity.y == 0:
		jump_count= 0
func play_jump_smoke():
	if jump_smoke_scene == null:
		return

	var smoke = jump_smoke_scene.instantiate()
	
	# Vị trí smoke (tùy bạn muốn đặt ở đâu)
	smoke.global_position = global_position + Vector2(0, 10) # hơi dưới chân
	
	# Thêm vào scene
	get_tree().current_scene.add_child(smoke)

func jump() -> void:
	if jump_count < max_jumps:
		var pv = get_platform_velocity()
		velocity.y = -jump_speed
		velocity.y -= pv.y
		jump_count += 1

		play_jump_sound()
		play_jump_smoke()

func show_shield_effect(active: bool) -> void:
	if $Direction.has_node("ShieldFX"):
		$Direction/ShieldFX.visible = active


func apply_shield_buff(duration: float):
	has_shield_buff = true
	shield_hits = 1  # chỉ chặn 1 lần sát thương
	shield_buff_timer = duration
	print("Shield buff activated for ", duration, " seconds")
	
	# bật hiệu ứng khiên
	show_shield_effect(true)
func remove_shield_buff():
	has_shield_buff = false
	shield_hits = 0
	print("Shield buff expired")

	# tắt hiệu ứng hình khiên
	show_shield_effect(false)

func take_damage(dmg: int) -> void:
	# Nếu đang bất tử → bỏ qua damage
	if is_invulnerable:
		return

	# Nếu có khiên → chặn 1 hit
	if has_shield_buff and shield_hits > 0:
		shield_hits -= 1
		print("Shield blocked the damage!")

		if shield_hits <= 0:
			remove_shield_buff()

		start_invulnerability(2.0)
		return

	# Không có khiên → nhận damage
	health -= dmg
	print("PLAYER HP:", health)

	# Bật bất tử
	start_invulnerability(2.0)

	# Nếu đang bất tử → bỏ qua damage
	if is_invulnerable:
		return

	# Nếu có khiên → chặn 1 hit
	if has_shield_buff and shield_hits > 0:
		shield_hits -= 1
		print("Shield blocked the damage!")
		
		# khiên hết hit → tắt buff
		if shield_hits <= 0:
			remove_shield_buff()

		# bất tử 2s sau khi shield absorb
		start_invulnerability(2.0)
		return

	# Nếu không có khiên → trừ máu
	health -= dmg

	# bất tử 2s sau khi bị damage thường
	start_invulnerability(2.0)

	if has_shield_buff and shield_hits > 0:
		shield_hits -= 1
		print("Shield blocked the damage!")

		if shield_hits <= 0:
			remove_shield_buff()

		return

	# Nếu không có khiên → gọi take_damage gốc
	health -= dmg
func _start_flicker():
	if flicker_tween:
		flicker_tween.kill()
		
	flicker_tween = create_tween().set_loops()  # loop vô hạn tới khi stop

	# nhấp nháy in/out
	flicker_tween.tween_property(self, "modulate:a", 0.2, 0.1)
	flicker_tween.tween_property(self, "modulate:a", 1.0, 0.1)
func _stop_flicker():
	if flicker_tween:
		flicker_tween.kill()
	modulate.a = 1.0

func start_invulnerability(duration: float = 2.0):
	is_invulnerable = true
	invulnerable_timer = duration

	# Bắt đầu flicker animation
	_start_flicker()
func end_invulnerability():
	is_invulnerable = false
	_stop_flicker()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if jump_count < max_jumps:
			jump()
			fsm.change_state(fsm.states.jump)
