extends KinematicBody2D

# Export fields
export (int) var speed = 80

# Onready fields
onready var target_position = position
onready var anim_player = $AnimationPlayer
onready var wraith_range = $Range

# Misc fields
var velocity = Vector2()

func _physics_process(_delta):
	run_actions()
	move()
	play_animation()


func run_actions():
	var dudes = get_tree().get_nodes_in_group("active_dude")
	if dudes.empty():
		wander()
	else:
		target_position = get_closest(dudes).global_position
		var bodies = wraith_range.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("active_dude"):
				body.lifespan = 0


func wander():
	if not target_position or position == target_position:
		var new_dir = Vector2(rand_range(-300, 300), rand_range(-300, 300))
		target_position = global_position + new_dir

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