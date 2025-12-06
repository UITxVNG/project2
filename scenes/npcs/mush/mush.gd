extends CharacterBody2D

@export var interaction_range: float = 50.0

var is_player_nearby: bool = false
var can_interact: bool = true

@onready var interaction_icon = $InteractionIcon if has_node("InteractionIcon") else null

func _ready() -> void:
	add_to_group("npcs")
	if interaction_icon:
		interaction_icon.visible = false

func _process(_delta: float) -> void:
	_check_player_distance()
	
	if is_player_nearby and can_interact:
		if interaction_icon:
			interaction_icon.visible = true
		
		if Input.is_action_just_pressed("interact"):
			_start_conversation()
	else:
		if interaction_icon:
			interaction_icon.visible = false

func _check_player_distance() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = global_position.distance_to(player.global_position)
		is_player_nearby = distance <= interaction_range
	else:
		is_player_nearby = false

func _start_conversation() -> void:
	if not can_interact or Dialogic.current_timeline != null:
		return
	
	can_interact = false
	
	# Chọn timeline dựa trên trạng thái game
	var timeline = _get_appropriate_timeline()
	
	# Dừng người chơi
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(false)
	
	# Bắt đầu hội thoại
	Dialogic.start(timeline)
	Dialogic.timeline_ended.connect(_on_conversation_ended)

func _get_appropriate_timeline() -> String:
	var game_manager = get_node("/root/GameManager")
	
	# Lần đầu gặp Mush
	if not game_manager.get_story_flag("mush_met"):
		return "map1_mush_first_meet"
	
	# Đã nhận kiếm
	elif game_manager.has_blade:
		return "mush_after_blade"
	
	# Sau khi biết sự thật (Map 9+)
	elif game_manager.get_story_flag("truth_discovered"):
		return "mush_after_truth"
	
	# Hội thoại mặc định
	else:
		return "mush_default"

func _on_conversation_ended() -> void:
	can_interact = true
	
	# Cho phép người chơi di chuyển
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_can_move"):
		player.set_can_move(true)
	
	# Đánh dấu đã gặp Mush
	var game_manager = get_node("/root/GameManager")
	if not game_manager.get_story_flag("mush_met"):
		game_manager.set_story_flag("mush_met", true)
	
	Dialogic.timeline_ended.disconnect(_on_conversation_ended)
