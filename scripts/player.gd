extends KinematicBody2D

export (int) var speed = 100
var velocity = Vector2()
onready var anim = $AnimationPlayer
onready var target = position

func _input(event):
	if event.is_action_pressed('click'):
		target = get_global_mouse_position()

func _physics_process(_delta):
	var play_anim = "rest"
	if (target - position).length() > 5:
		velocity = (target - position).normalized() * speed
		velocity = move_and_slide(velocity)
		
		if velocity.x != 0 and velocity.y != 0:
			if velocity.y > 0 and velocity.x < 0:
				play_anim = "walk_down_left"
			if velocity.y > 0 and velocity.x > 0:
				play_anim = "walk_down_right"
			if velocity.y < 0 and velocity.x < 0:
				play_anim = "walk_up_left"
			if velocity.y < 0 and velocity.x > 0:
				play_anim = "walk_up_right"
		else:
			if velocity.x < 0:
				play_anim = "walk_left"
			if velocity.x > 0:
				play_anim = "walk_right"
			if velocity.y > 0:
				play_anim = "walk_down"
			if velocity.y < 0:
				play_anim = "walk_up"
	else:
	anim.play(play_anim)
