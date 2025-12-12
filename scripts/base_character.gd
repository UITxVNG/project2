class_name BaseCharacter
extends CharacterBody2D

## Base character class that provides common functionality for all characters

@export var movement_speed: float = 200.0
@export var gravity: float = 700.0
@export var direction: int = 1
@export var ignore_gravity: bool = false
@export var attack_damage: int = 1
@export var max_health: int = 10
var health: int = max_health
@export var max_mana: float = 100
var mana: float = max_mana

var jump_speed: float = 320.0
var fsm: FSM = null
var current_animation = null
var animated_sprite: AnimatedSprite2D = null

var _next_animation = null
var _next_direction: int = 1
var _next_animated_sprite: AnimatedSprite2D = null

func _ready() -> void:
	set_animated_sprite($Direction/AnimatedSprite2D)

func _physics_process(delta: float) -> void:
	# Animation
	_check_changed_animation()
	if mana < max_mana:
		mana += delta * 2  # tốc độ hồi
		mana = min(mana, max_mana)

	if fsm != null:
		fsm._update(delta)
	# Movement
	_update_movement(delta)
	# Direction
	_check_changed_direction()


func _update_movement(delta: float) -> void:
	velocity.y += gravity * delta
	move_and_slide()
	pass

func turn_around() -> void:
	if _next_direction != direction:
		return
	_next_direction = -direction

func is_left() -> bool:
	return direction == -1

func is_right() -> bool:
	return direction == 1

func turn_left() -> void:
	_next_direction = -1

func turn_right() -> void:
	_next_direction = 1

func jump() -> void:
	if is_on_floor():
		var pv = get_platform_velocity()
		velocity.y = -jump_speed
		velocity.y -= pv.y   # triệt tiêu ngay sau khi áp jump force


func attack() -> void:
	pass
func stop_move() -> void:
	velocity.x = 0
	velocity.y = 0

func take_damage(damage: int) -> void:
	health -= damage

# Change the animation of the character on the next frame
func change_animation(new_animation: String) -> void:
	_next_animation = new_animation

# Change the direction of the character on the last frame
func change_direction(new_direction: int) -> void:
	_next_direction = new_direction

# Get the name of the current animation
func get_animation_name() -> String:
	return current_animation.name

func set_animated_sprite(new_animated_sprite: AnimatedSprite2D) -> void:
	# Tắt tất cả AnimatedSprite2D trong Direction
	for child in $Direction.get_children():
		if child is AnimatedSprite2D:
			child.visible = false
			child.stop()

	# Lưu sprite mới
	_next_animated_sprite = new_animated_sprite


func _check_changed_animation() -> void:
	var need_play := false

	# === Nếu đổi AnimatedSprite2D ===
	if _next_animated_sprite != animated_sprite:

		# 1) Tắt tất cả AnimatedSprite2D trong Direction
		for child in $Direction.get_children():
			if child is AnimatedSprite2D:
				child.visible = false
				child.stop()

		# 2) Set sprite mới
		animated_sprite = _next_animated_sprite
		
		# 3) Bật sprite mới
		if animated_sprite != null:
			animated_sprite.visible = true

		need_play = true


	# === Nếu đổi animation ===
	if _next_animation != current_animation:
		current_animation = _next_animation
		need_play = true


	# === Play animation nếu cần ===
	if need_play and animated_sprite != null and current_animation != null:
		animated_sprite.play(current_animation)


# Check if the direction has changed and set the new direction
func _check_changed_direction() -> void:
	if _next_direction != direction:
		direction = _next_direction
		_on_changed_direction()
		if direction == -1:
			$Direction.scale.x = -1
		if direction == 1:
			$Direction.scale.x = 1

# On changed direction
func _on_changed_direction() -> void:
	pass
