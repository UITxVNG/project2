class_name Player
extends BaseCharacter

var decorator_manager: DecoratorManager = null

## Player character class that handles movement, combat, and state management
var is_invulnerable: bool = false
var invulnerable_timer: float = 0.0
var flicker_tween: Tween
var is_dead: bool = false
var orb_exists: bool = false
var orb_angle: float = 0.0
var orb_distance: float = 180.0
var orb_rotate_speed: float = 3.0
var saved_sprite_before_ultra: AnimatedSprite2D = null

@export var has_blade: bool = false
@export var has_hammer: bool = false
var is_ultra: bool = false

@onready var bullet_factory := $Direction/BulletFactory
var wall_cling_lockout: float = 0.0

var has_double_jump_buff: bool = false
var jump_count: int = 0
var max_jumps: int = 1
var double_jump_buff_timer: float = 0.0
var walk_smoke_timer: float = 0.0
var unlock_hammer: bool = false   # có buff thì mới dùng được
var ultra_mana_drain_rate := 10.0 # mana mỗi giây
var ultra_timer := 0.0

var has_shield_buff: bool = false
var shield_buff_timer: float = 0.0
var shield_hits: int = 0
var base_speed := 0.0
var base_damage := 0
var base_jump := 0

@export var jump_smoke_scene: PackedScene
@export var walk_smoke_scene: PackedScene
@export var hammer_scene: PackedScene

func _ready() -> void:
	super._ready()
	base_speed = movement_speed
	base_damage = attack_damage
	base_jump = max_jumps
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
	if is_ultra:
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
	if not spend_mana(10):
		return  # không đủ mana thì không ném
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
	if orb_exists:
		orb_angle += orb_rotate_speed * delta

		var offset = Vector2(
			cos(orb_angle) * orb_distance,
			sin(orb_angle) * orb_distance
		)

		$TeleportOrb.global_position = global_position + offset
	if is_ultra:
		ultra_timer += delta
		if ultra_timer >= 1.0:
			ultra_timer = 0.0
			mana -= ultra_mana_drain_rate
			
			if mana <= 0:
				mana = 0
				print("Not enough mana! Ultra form cancelled.")
				_end_ultra_form()
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
		if unlock_hammer and spend_mana(20):
			fsm.change_state(fsm.states.crush)


func play_walk_smoke():
	if walk_smoke_scene == null:
		return

	var smoke = walk_smoke_scene.instantiate()
	smoke.global_position = global_position + Vector2(0, -3)   # tùy hiệu ứng
	get_tree().current_scene.add_child(smoke)


func _on_hit_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()

	if parent is Rock:
		if is_ultra:
			parent.crush_break()
			return

		if fsm.current_state == fsm.states.crush:
			parent.crush_break()



func spawn_orb():
	orb_exists = true
	$TeleportOrb.visible = true
	orb_angle = 0.0

func heal():
	if GameManager.inventory_system.health_potions > 0 and health < max_health:
		GameManager.inventory_system.health_potions -= 1
		health = min(health + 3, max_health)
		print("Used potion. HP:", health)
		
func use_mana_potion():
	if GameManager.inventory_system.mana_potions > 0 and mana < max_mana:
		GameManager.inventory_system.mana_potions -= 1
		mana = min(mana + 30, max_mana)  # tăng bao nhiêu tùy bạn (5,10,20...)
		print("Used mana potion. Mana:", mana)
	else:
		print("Cannot use mana potion!") 


func _input(event):
	if event.is_action_pressed("teleport"):
		if orb_exists:
			if spend_mana(20):
				teleport_to_orb()
		else:
			if spend_mana(20):
				spawn_orb()

	if event.is_action_pressed("heal"):
		heal()
	if event.is_action_pressed("mana"):
		use_mana_potion()
	if event.is_action_pressed("transform"):
		transform_ultra()
func transform_ultra():
	if not is_ultra:
		_start_ultra_form()
	else:
		_end_ultra_form()

func _start_ultra_form():
	if mana < 80:
		print("Not enough mana to transform!")
		return

	is_ultra = true
	saved_sprite_before_ultra = animated_sprite
	print("The sprite saved", saved_sprite_before_ultra)
	movement_speed = base_speed * 1.5
	attack_damage = base_damage + 3

	has_double_jump_buff = true
	max_jumps = base_jump + 2   # từ 1 → 3
	# Animation biến hình
	change_animation("transform")
	await animated_sprite.animation_finished

	# Đổi sang sprite Ultra
	set_animated_sprite($Direction/UltraFoxAnimatedSprite2D)
	change_animation("idle")

	print("ULTRA MODE ON")
func _end_ultra_form():
	is_ultra = false
	movement_speed = base_speed
	attack_damage = base_damage

	has_double_jump_buff = false
	max_jumps = base_jump
	if saved_sprite_before_ultra != null:
		set_animated_sprite(saved_sprite_before_ultra)
	else:
		set_animated_sprite($Direction/AnimatedSprite2D)
	change_animation("idle")

	print("ULTRA MODE OFF")

func teleport_to_orb():
	global_position = $TeleportOrb.global_position
	$TeleportOrb.visible = false
	orb_exists = false
	
func spend_mana(amount: int) -> bool:
	if mana >= amount:
		mana -= amount
		return true
	else:
		print("Not enough mana!")
		return false
