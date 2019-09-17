extends KinematicBody2D

export (int) var speed = 100

onready var target = position
var velocity = Vector2()

onready var anim = $AnimationPlayer
onready var line = $"LineOfSight"

var checked = [get_instance_id()]

class_name Pig

func _input(event):
	if event.is_action_pressed('click'):
		target = get_global_mouse_position()

func _physics_process(_delta):
	velocity = (target - position).normalized() * speed
	if (target - position).length() > 5:
		velocity = move_and_slide(velocity)
		
		var play_animation = "rest"
		
		if velocity[0] > 0:
			play_animation = "walk_right"
		else:
			play_animation = "walk_left"
		
		if abs(velocity[0]) < abs(velocity[1]):
			if velocity[1] > 0:
				play_animation = "walk_down"
			else:
				play_animation = "walk_up"
		
		anim.play(play_animation)
	else:
		var bodies = line.get_overlapping_bodies()
		for body in bodies:
			if !checked.has(body.get_instance_id()) and body.is_in_group("Entity"):
				target = body.position
				checked.append(body.get_instance_id())
				break