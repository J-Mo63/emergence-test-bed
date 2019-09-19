extends KinematicBody2D

export (int) var speed = 100
var velocity = Vector2()
onready var anim = $AnimationPlayer

func _physics_process(_delta):
	var temp_velocity = Vector2()
	if Input.is_action_pressed('right'):
		temp_velocity.x += 1
	if Input.is_action_pressed('left'):
		temp_velocity.x -= 1
	if Input.is_action_pressed('down'):
		temp_velocity.y += 1
	if Input.is_action_pressed('up'):
		temp_velocity.y -= 1
		
	velocity = temp_velocity.normalized() * speed
	velocity = move_and_slide(velocity)
	
	var play_anim
	print(str(temp_velocity.x) + ', ' + str(temp_velocity.y))
	if temp_velocity.x != 0 and temp_velocity.y != 0:
		if temp_velocity.y == 1 and temp_velocity.x == -1:
			play_anim = "walk_down_left"
		if temp_velocity.y == 1 and temp_velocity.x == 1:
			play_anim = "walk_down_right"
		if temp_velocity.y == -1 and temp_velocity.x == -1:
			play_anim = "walk_up_left"
		if temp_velocity.y == -1 and temp_velocity.x == 1:
			play_anim = "walk_up_right"
	elif temp_velocity.x == 0 and temp_velocity.y == 0:
		play_anim = "rest"
	else:
		if temp_velocity.x == -1:
			play_anim = "walk_left"
		if temp_velocity.x == 1:
			play_anim = "walk_right"
		if temp_velocity.y == 1:
			play_anim = "walk_down"
		if temp_velocity.y == -1:
			play_anim = "walk_up"
	
	anim.play(play_anim)