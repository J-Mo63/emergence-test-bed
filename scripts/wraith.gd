extends KinematicBody2D

# Export fields
export (int) var speed = 80

# Onready fields
onready var target_position = position
onready var anim_player = $AnimationPlayer
onready var wraith_range = $Range
onready var day_night_cycle = get_node("/root/Node2D/DayNightCycle")

# Misc fields
var velocity = Vector2()

func _physics_process(_delta):
	run_actions()
	move()
	play_animation()


func run_actions():
	var dudes = get_tree().get_nodes_in_group("active_dude")
	if day_night_cycle.is_night and not dudes.empty():
		target_position = get_closest(dudes).global_position
		var bodies = wraith_range.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("active_dude"):
				body.lifespan = 0
	else:
		wander()


func wander():
	if not target_position or position == target_position:
		var new_dir = Vector2(rand_range(-300, 300), rand_range(-300, 300))
		var new_loc = global_position + new_dir
		if new_loc.x > -250 and new_loc.x < 1250 and new_loc.y > -250 and new_loc.y < 750:
			target_position = new_loc

func get_closest(values):
	var closest_value = values[0]
	for value in values:
		var current_len = (position - closest_value.global_position).length()
		var potential_len = (position - value.global_position).length()
		if potential_len < current_len:
			closest_value = value
	return closest_value


func move():
	if target_position:
		if (target_position - position).length() > 30:
			velocity = (target_position - position).normalized() * speed
			velocity = move_and_slide(velocity)
		else:
			velocity = Vector2()
			target_position = null


func play_animation():
	var play_anim
	if velocity.x == 0 and velocity.y == 0:
		play_anim = "rest"
	else:
		if velocity.x < 0:
			play_anim = "float_left"
		if velocity.x > 0:
			play_anim = "float_right"
	anim_player.play(play_anim)