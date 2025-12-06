extends CharacterBody2D

@export var damage := 3
@export var fall_speed := 800
var direction := 1
func _physics_process(delta):
	velocity.y = fall_speed
	move_and_slide()
