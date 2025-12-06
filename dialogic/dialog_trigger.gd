# dialog_trigger.gd
# Script này có thể gắn vào NPC hoặc trigger area để kích hoạt hội thoại

extends Area2D

@export var timeline_name: String = ""
@export var trigger_once: bool = true
@export var auto_start: bool = false  # Tự động chạy khi vào vùng
@export var require_interaction: bool = true  # Cần nhấn phím tương tác

var is_player_nearby: bool = false
var has_triggered: bool = false
var can_interact: bool = false

@onready var interaction_label = $InteractionLabel if has_node("InteractionLabel") else null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if interaction_label:
		interaction_label.visible = false

func _process(_delta: float) -> void:
	if is_player_nearby and can_interact:
		if require_interaction:
			if Input.is_action_just_pressed("interact"):
				start_dialog()
		elif auto_start and not has_triggered:
			start_dialog()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		can_interact = true
		
		if interaction_label:
			interaction_label.visible = require_interaction
		
		if auto_start and not has_triggered:
			start_dialog()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		can_interact = false
		
		if interaction_label:
			interaction_label.visible = false

func start_dialog() -> void:
	if timeline_name == "" or Dialogic.current_timeline != null:
		return
	
	if trigger_once and has_triggered:
		return
	
	has_triggered = true
	can_interact = false
	
	if interaction_label:
		interaction_label.visible = false
	
	# Dừng người chơi lại
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)
	
	# Bắt đầu timeline
	Dialogic.start(timeline_name)
	
	# Kết nối signal khi hội thoại kết thúc
	var timeline = Dialogic.timeline_ended.connect(_on_timeline_ended)

func _on_timeline_ended() -> void:
	# Cho phép người chơi di chuyển lại
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)
	
	# Reset trạng thái nếu không phải trigger_once
	if not trigger_once:
		has_triggered = false
		can_interact = true
	
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
