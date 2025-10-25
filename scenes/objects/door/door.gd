
extends Node2D


@export_file("*.tscn") var target_stage = ""

@export var target_door = "Door"


func load_next_stage():

	# load next stage with target door name

	GameManager.change_stage(target_stage, target_door)


func _on_interactive_area_2d_interacted() -> void:

	load_next_stage()
