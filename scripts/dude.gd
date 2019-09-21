extends KinematicBody2D

# Public fields
export (int) var speed = 100

# Private fields
var velocity = Vector2()
onready var target = position
onready var anim_player = $AnimationPlayer
onready var dude_range = $Range
var item


func _physics_process(_delta):
	move()
	play_animation()


func move():
	if (target - position).length() > 30:
		velocity = (target - position).normalized() * speed
		velocity = move_and_slide(velocity)
	else:
		#target = get_random_screen_location()
		velocity = Vector2()
		
		if item:
			deposit_items()
		else:
			gather_items()


func play_animation():
	var play_anim
	if velocity.x != 0 and velocity.y != 0:
		if velocity.y > 0 and velocity.x < 0:
			play_anim = "walk_down_left"
		if velocity.y > 0 and velocity.x > 0:
			play_anim = "walk_down_right"
		if velocity.y < 0 and velocity.x < 0:
			play_anim = "walk_up_left"
		if velocity.y < 0 and velocity.x > 0:
			play_anim = "walk_up_right"
	elif velocity.x == 0 and velocity.y == 0:
		play_anim = "rest"
	else:
		if velocity.x < 0:
			play_anim = "walk_left"
		if velocity.x > 0:
			play_anim = "walk_right"
		if velocity.y > 0:
			play_anim = "walk_down"
		if velocity.y < 0:
			play_anim = "walk_up"
	anim_player.play(play_anim)


func deposit_items():
	for body in dude_range.get_overlapping_bodies():
		if body.is_in_group("depot"):
			body._deposit(item)
			item = null
			$BodySprite/ItemSprite.texture = item
			pass
	var depots = get_tree().get_nodes_in_group("depot")
	if depots:
		target = depots[0].position


func gather_items():
	for body in dude_range.get_overlapping_bodies():
		if body.is_in_group("resource"):
			item = body._cut()
			if item:
				var image_texture = ImageTexture.new()
				image_texture.create_from_image(load("res://assets/sprites/" + item + ".png"))
				image_texture.set_flags(Texture.FLAG_FILTER)
				$BodySprite/ItemSprite.texture = image_texture
			pass
	var resources = get_tree().get_nodes_in_group("resource")
	if resources:
		target = resources[0].position


func get_random_screen_location():
	var rand_x = rand_range(0, get_viewport().size.x + 1)
	var rand_y = rand_range(0, get_viewport().size.y + 1)
	return Vector2(rand_x, rand_y)