extends KinematicBody2D

export (int) var speed = 100

var target = Vector2()
var velocity = Vector2()

onready var anim = $AnimationPlayer
onready var line = $"LineOfSight"

class_name Pig

func _input(event):
	if event.is_action_pressed('click'):
		target = get_global_mouse_position()

func _process(_delta):
	var bodies = line.get_overlapping_bodies()
	
	for body in bodies:
		if body.get_instance_id () != get_instance_id () and body.is_in_group("Entity"):
			target = body.position

func _physics_process(_delta):
	velocity = (target - position).normalized() * speed
	if (target - position).length() > 5:
		velocity = move_and_slide(velocity)
		anim.play("walk_right")
	else:
		anim.play("rest")