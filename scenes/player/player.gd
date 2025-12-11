class_name Player
extends BaseCharacter

var decorator_manager: DecoratorManager = null

## Player character class that handles movement, combat, and state management
var is_invulnerable: bool = false
var invulnerable_timer: float = 0.0
var flicker_tween: Tween
var is_dead: bool = false

@export var has_blade: bool = false
@export var has_hammer: bool = false

@onready var bullet_factory := $Direction/BulletFactory
var wall_cling_lockout: float = 0.0

var has_double_jump_buff: bool = false
var jump_count: int = 0
var max_jumps: int = 1
var double_jump_buff_timer: float = 0.0
var walk_smoke_timer: float = 0.0
var unlock_hammer: bool = false   # có buff thì mới dùng được

var has_shield_buff: bool = false
var shield_buff_timer: float = 0.0
var shield_hits: int = 0

@export var jump_smoke_scene: PackedScene
@export var walk_smoke_scene: PackedScene
@export var hammer_scene: PackedScene


func _ready() -> void:
	super._ready()
	fsm = FSM.new(self, $States, $States/Idle)
	$HurtArea2D.hurt.connect(_on_hurt_area_2d_hurt)

	# Decorator manager
	decorator_manager = DecoratorManager.new()
	decorator_manager.initialize(self)
	add_child(decorator_manager)

	# Add to player group for Area2D detection
	add_to_group("player")

	GameManager.player = self


# ============================================================
# SAVE / LOAD
# ============================================================
func save_state() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y]
	}

func load_state(data: Dictionary) -> void:
	if data.has("position"):
		var pos_array = data["position"]
		global_position = Vector2(pos_array[0], pos_array[1])


# ============================================================
# DECORATOR OVERRIDES
# ============================================================
func can_attack() -> bool:
	if decorator_manager != null:
		if decorator_manager.can_blade_attack():
			return true

	# blade dùng cho ném
	if has_blade:
		return true	

	# hammer dùng cho crush
	if has_hammer:
		return true

	return false

func get_movement_speed():
	if decorator_manager != null:
		return decorator_manager.get_effective_movement_speed()
	return movement_speed

func get_jump_speed():
	if decorator_manager != null:
		return decorator_manager.get_effective_jump_speed()
	return jump_speed


# ============================================================
# SPEED BUFF (from your first Player code)
# ============================================================
func speed_up(multiplier: float, duration: float) -> void:
	movement_speed = movement_speed * multiplier
	await get_tree().create_timer(duration).timeout
	movement_speed = movement_speed / multiplier


# ============================================================
# BLADE
# ============================================================
func collected_blade() -> void:
	has_blade = true
	GameManager.has_blade = true
	set_animated_sprite($Direction/BladeAnimatedSprite2D)
func collected_hammer() -> void:
	has_hammer = true
	GameManager.has_hammer = true

	set_animated_sprite($Direction/HammerAnimatedSprite2D)

func throw_blade(speed: float) -> void:
	var blade = bullet_factory.create() as RigidBody2D

	blade.global_position = $Direction/FirePoint.global_position

	# Set hướng bay ngay từ đầu
	blade.direction = direction
	blade.player = self
	blade.speed = speed

	# Cho nó bay ra bằng linear_velocity (optimization)
	blade.linear_velocity = Vector2(direction * speed, 0)




# ============================================================
# POWERUP
# ============================================================
func collect_powerup(powerup_id: String) -> void:
	if decorator_manager:
		decorator_manager.apply_powerup(powerup_id)


# ============================================================
# JUMP SYSTEM
# ============================================================
func play_jump_smoke():
	if jump_smoke_scene == null:
		return
	var smoke = jump_smoke_scene.instantiate()
	smoke.global_position = global_position + Vector2(0, -7)
	get_tree().current_scene.add_child(smoke)

func jump() -> void:
	if jump_count < max_jumps:
		var pv = get_platform_velocity()
		velocity.y = -get_jump_speed()
		velocity.y -= pv.y
		jump_count += 1

		play_jump_sound()
		play_jump_smoke()

func play_jump_sound() -> void:
	$Jump.play()


# ============================================================
# INVULNERABILITY
# SHIELD
# ============================================================
func take_damage(dmg: int) -> void:
	# Already invulnerable? ignore
	if is_invulnerable:
		return

	# Decorators first
	if decorator_manager:
		dmg = decorator_manager.get_effective_damage_taken(dmg)

	# If shield absorbed full damage
	if dmg <= 0:
		return

	# Do actual damage
	super.take_damage(dmg)

	# Trigger invulnerability + flicker + animation
	start_invulnerability(1.0)  # duration tùy bạn



func _start_flicker():
	if flicker_tween:
		flicker_tween.kill()

	flicker_tween = create_tween().set_loops()
	flicker_tween.tween_property(self, "modulate:a", 0.2, 0.1)
	flicker_tween.tween_property(self, "modulate:a", 1.0, 0.1)

func _stop_flicker():
	if flicker_tween:
		flicker_tween.kill()
	modulate.a = 1.0

func start_invulnerability(duration: float = 2.0):
	is_invulnerable = true
	invulnerable_timer = duration
	_start_flicker()

func end_invulnerability():
	is_invulnerable = false
	_stop_flicker()


# ============================================================
# HURT
# ============================================================
func _on_hurt_area_2d_hurt(_direction: Variant, _damage: Variant) -> void:
	fsm.current_state.take_damage(_damage)


# ============================================================
# PHYSICS
# ============================================================
func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if is_invulnerable:
		invulnerable_timer -= delta
		if invulnerable_timer <= 0:
			end_invulnerability()
	# Decrease timer
	if walk_smoke_timer > 0:
		walk_smoke_timer -= delta

	# RESET JUMP
	if is_on_floor() and velocity.y == 0:
		jump_count = 0

func summon_hammer():
	var hammer = hammer_scene.instantiate()

	# Spawn TRƯỚC MẶT và CAO HƠN player
	var x_offset = 60 * direction      # lệch sang hướng player nhìn
	var y_offset = -100                # cao lên để tạo hiệu ứng rơi

	hammer.global_position = global_position + Vector2(x_offset, y_offset)

	hammer.direction = direction
	get_tree().current_scene.add_child(hammer)


# ============================================================
# INPUT
# ============================================================
func _unhandled_input(event: InputEvent) -> void:
	if is_dead:
		return  # CHẶN TOÀN BỘ INP
	if event.is_action_pressed("jump"):
		if jump_count < max_jumps:
			jump()
			fsm.change_state(fsm.states.jump)
	if event.is_action_pressed("special"):
		if unlock_hammer:
			fsm.change_state(fsm.states.crush)

func play_walk_smoke():
	if walk_smoke_scene == null:
		return

	var smoke = walk_smoke_scene.instantiate()
	smoke.global_position = global_position + Vector2(0, -3)   # tùy hiệu ứng
	get_tree().current_scene.add_child(smoke)


func _on_hit_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Rock:
		area.get_parent().crush_break()
