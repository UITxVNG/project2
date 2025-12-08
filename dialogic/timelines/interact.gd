extends Area2D

@export var hint_text: String = "Nhấn F để tương tác"
@export var show_duration: float = 0.3

@onready var text_label = $TextPanel/Label
@onready var text_panel = $TextPanel

var tween: Tween

func _ready():
	hide_hint()
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	text_label.text = hint_text

func _on_body_entered(body):
	if body.name == "Player":
		show_hint()

func _on_body_exited(body):
	if body.name == "Player":
		hide_hint()

func show_hint():
	text_panel.visible = true
	text_panel.modulate.a = 0
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(text_panel, "modulate:a", 1.0, show_duration)

func hide_hint():
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(text_panel, "modulate:a", 0.0, show_duration)
	await tween.finished
	text_panel.visible = false
