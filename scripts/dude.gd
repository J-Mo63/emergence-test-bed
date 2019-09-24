extends KinematicBody2D

# Public fields
export (int) var speed = 100

# Private fields
var velocity = Vector2()
onready var target = self
onready var target_position = position
onready var anim_player = $AnimationPlayer
onready var dude_range = $Range
var item


func _physics_process(_delta):
	move()
	play_animation()


func move():
	if (target_position - position).length() > 30:
		velocity = (target_position - position).normalized() * speed
		velocity = move_and_slide(velocity)
	else:
		velocity = Vector2()
		if item:
			deposit_items()
		else:
			gather_items()


func deposit_items():
	for area in dude_range.get_overlapping_areas():
		if area.is_in_group("depot"):
			area._deposit(item)
			item = null
			$BodySprite/ItemSprite.texture = item
			pass
	var depots = get_tree().get_nodes_in_group("depot")
	if depots:
		target_position = depots[0].position


func gather_items():
	var areas = dude_range.get_overlapping_areas()
	for area in areas:
		if area == target:
			item = area._gather()
			if item:
				var image_texture = ImageTexture.new()
				image_texture.create_from_image(load("res://assets/sprites/" + item + ".png"))
				image_texture.set_flags(Texture.FLAG_FILTER)
				$BodySprite/ItemSprite.texture = image_texture
			pass
	var resources = get_tree().get_nodes_in_group("resource")
	filter_areas(resources)
	if resources:
		target = get_closest(resources)
		target_position = target.global_position
		print(target_position)


func filter_areas(areas):
	for i in range(areas.size()):
		if areas[i].get_groups().has("group"):
			areas.remove(i)


func get_closest(values):
	var closest_value = values[0]
	for value in values:
		var current_len = (position - closest_value.global_position).length()
		var potential_len = (position - value.global_position).length()
		if potential_len < current_len:
			closest_value = value
	return closest_value


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