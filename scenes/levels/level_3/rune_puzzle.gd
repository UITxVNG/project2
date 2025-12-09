# scripts/puzzles/rune_puzzle.gd
extends Node2D

## Rune Puzzle - Player phải sắp xếp các biểu tượng theo đúng thứ tự

@export var correct_sequence: Array[String] = ["fire", "water", "earth", "tree"]
@export var puzzle_door: AnimatableBody2D  # Assign trong Editor
@export var artifact_spawn_point: Node2D  # Vị trí spawn artifact sau khi giải

var current_sequence: Array[String] = []
var is_solved: bool = false
var dragging_symbol: Node2D = null

# Slots
@onready var slots = $RuneSlots.get_children()
@onready var symbols = $RuneSymbols.get_children()
@onready var hint_label = $PuzzleHint
@onready var completion_effect = $CompletionEffect
@onready var solve_sound = $SolveSound

signal puzzle_solved

func _ready() -> void:
	# Setup symbols
	for symbol in symbols:
		if symbol is Area2D:
			symbol.input_event.connect(_on_symbol_input_event.bind(symbol))
	
	# Setup slots
	for i in range(slots.size()):
		var slot = slots[i]
		#if slot.has_signal("body_entered"):
			#slot.body_entered.connect(_on_slot_entered.bind(i))
	
	# Ẩn hint ban đầu
	if hint_label:
		hint_label.visible = false

func _process(delta: float) -> void:
	if dragging_symbol != null:
		# Follow mouse
		dragging_symbol.global_position = get_global_mouse_position()

func _on_symbol_input_event(viewport: Node, event: InputEvent, shape_idx: int, symbol: Node2D) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_dragging(symbol)
			else:
				_stop_dragging()

func _start_dragging(symbol: Node2D) -> void:
	if is_solved:
		return
	
	dragging_symbol = symbol
	symbol.z_index = 100  # Đưa lên trên

func _stop_dragging() -> void:
	if dragging_symbol == null:
		return
	
	# Check if dropped on a slot
	var dropped_on_slot = _get_slot_at_position(dragging_symbol.global_position)
	
	if dropped_on_slot != -1:
		_place_symbol_in_slot(dragging_symbol, dropped_on_slot)
	else:
		# Return to original position
		dragging_symbol.global_position = dragging_symbol.get_meta("original_position", dragging_symbol.global_position)
	
	dragging_symbol.z_index = 0
	dragging_symbol = null

func _get_slot_at_position(pos: Vector2) -> int:
	for i in range(slots.size()):
		var slot = slots[i]
		var distance = pos.distance_to(slot.global_position)
		if distance < 50:  # Khoảng cách threshold
			return i
	return -1

func _place_symbol_in_slot(symbol: Node2D, slot_index: int) -> void:
	# Move symbol to slot
	var slot = slots[slot_index]
	symbol.global_position = slot.global_position
	
	# Update current sequence
	var symbol_type = symbol.get_meta("symbol_type", "")
	
	if current_sequence.size() > slot_index:
		current_sequence[slot_index] = symbol_type
	else:
		current_sequence.append(symbol_type)
	
	print("Placed %s in slot %d" % [symbol_type, slot_index])
	
	# Check if all slots filled
	if current_sequence.size() == correct_sequence.size():
		_check_solution()

func _check_solution() -> void:
	print("Checking solution: ", current_sequence, " vs ", correct_sequence)
	
	var is_correct = true
	for i in range(correct_sequence.size()):
		if current_sequence[i] != correct_sequence[i]:
			is_correct = false
			break
	
	if is_correct:
		_on_puzzle_solved()
	else:
		_on_puzzle_failed()

func _on_puzzle_solved() -> void:
	is_solved = true
	print("Puzzle solved! 🎉")
	
	# Play effects
	if solve_sound:
		solve_sound.play()
	
	if completion_effect:
		completion_effect.emitting = true
	
	# Open door
	if puzzle_door:
		_open_door()
	
	# Show dialog
	await get_tree().create_timer(1.0).timeout
	Dialogic.start("puzzle_solved")
	
	puzzle_solved.emit()

func _on_puzzle_failed() -> void:
	print("Wrong solution! Try again.")
	
	# Reset puzzle
	await get_tree().create_timer(0.5).timeout
	_reset_symbols()
	current_sequence.clear()

func _reset_symbols() -> void:
	# Return symbols to original positions
	for symbol in symbols:
		if symbol.has_meta("original_position"):
			var tween = create_tween()
			tween.tween_property(symbol, "global_position", symbol.get_meta("original_position"), 0.5)

func _open_door() -> void:
	if puzzle_door == null:
		return
	
	# Animation mở cửa
	var tween = create_tween()
	tween.tween_property(puzzle_door, "position:y", puzzle_door.position.y - 200, 2.0).set_ease(Tween.EASE_IN_OUT)
	
	# Disable collision
	await tween.finished
	puzzle_door.collision_layer = 0
	puzzle_door.collision_mask = 0
	
	print("Door opened!")

# Show hint khi player vào gần
func show_hint() -> void:
	if hint_label and not is_solved:
		hint_label.visible = true
		hint_label.text = "Sắp xếp theo thứ tự: 🔥 → 💧 → 🌍 → 💨"

func hide_hint() -> void:
	if hint_label:
		hint_label.visible = false
