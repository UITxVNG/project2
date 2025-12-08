# scenes/collectibles/artifact.gd
extends Area2D
class_name Artifact

## Di Vật có thể thu thập - Là phần của Lõi Năng Lượng Thiên Thể

@export_group("Artifact Settings")
@export var artifact_id: int = 1  # ID từ 1-7
@export var artifact_name: String = "Di Vật Biển Sâu"
@export var artifact_description: String = "Một mảnh của Lõi Năng Lượng"

@export_group("Visual Effects")
@export var glow_color: Color = Color(0.0, 0.8, 1.0)  # Màu ánh sáng
@export var float_amplitude: float = 10.0  # Độ cao của animation lơ lửng
@export var float_speed: float = 2.0
@export var rotate_speed: float = 1.0

@export_group("Audio")
@export var collect_sound: AudioStream

# Internal
var start_position: Vector2
var time_passed: float = 0.0
var is_collected: bool = false

@onready var sprite = $Sprite2D
@onready var glow_particles = $GlowParticles if has_node("GlowParticles") else null
@onready var light = $PointLight2D if has_node("PointLight2D") else null
@onready var audio_player = $AudioStreamPlayer if has_node("AudioStreamPlayer") else null
@onready var collision_shape = $CollisionShape2D

func _ready() -> void:
	add_to_group("artifacts")
	start_position = global_position
	
	# Setup visual effects
	if light:
		light.color = glow_color
	
	if glow_particles:
		glow_particles.emitting = true
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	
	# Check if already collected (từ save game)
	_check_if_already_collected()

func _check_if_already_collected() -> void:
	# Kiểm tra xem artifact này đã được thu thập chưa
	var collected_artifacts = GameManager.get_collected_artifact_ids()
	if artifact_id in collected_artifacts:
		queue_free()  # Xóa artifact nếu đã thu thập

func _physics_process(delta: float) -> void:
	if is_collected:
		return
	
	time_passed += delta
	
	# Animation lơ lửng (floating)
	var new_y = start_position.y + sin(time_passed * float_speed) * float_amplitude
	global_position.y = new_y
	
	## Animation xoay
	#if sprite:
		#sprite.rotation += rotate_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	
	if body.is_in_group("player"):
		_collect()

func _collect() -> void:
	if is_collected:
		return
	
	is_collected = true
	
	# Play sound
	if audio_player and collect_sound:
		audio_player.stream = collect_sound
		audio_player.play()
	
	# Play collect animation
	_play_collect_animation()
	
	# Gọi GameManager
	GameManager.collect_artifact_with_id(artifact_id, artifact_name)
	
	# Show popup hoặc dialog
	_show_artifact_popup()
	
	# Kích hoạt Dialogic timeline nếu có
	_trigger_dialogic_event()

func _play_collect_animation() -> void:
	# Tween animation: scale up và fade out
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Scale up
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Fade out
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	
	if light:
		tween.tween_property(light, "energy", 0.0, 0.5)
	
	if glow_particles:
		glow_particles.emitting = false
	
	# Xóa sau khi animation xong
	tween.tween_callback(queue_free).set_delay(0.5)

func _show_artifact_popup() -> void:
	# Hiện popup thông báo đã thu thập Di Vật
	# Bạn có thể tạo UI popup riêng hoặc dùng Dialogic
	print("✨ Đã thu thập: %s (ID: %d)" % [artifact_name, artifact_id])

func _trigger_dialogic_event() -> void:
	# Kích hoạt timeline Dialogic tương ứng với số artifact
	match GameManager.artifacts_collected:
		1:
			# Di Vật đầu tiên - Giọng nói khuyến khích
			Dialogic.start("artifact_1_collected")
		3:
			# Di Vật thứ 3 - Thế giới bắt đầu thay đổi
			Dialogic.start("artifact_3_collected")
		5:
			# Di Vật thứ 5 - Cảnh báo nghiêm trọng
			Dialogic.start("artifact_5_collected")
		7:
			# Di Vật cuối cùng - Có thể vào Final Boss
			Dialogic.start("artifact_7_collected")
