extends KinematicBody2D

# Public fields
export (int) var speed = 100
export (int) var max_hunger = 3000

# Private fields
var hunger = max_hunger
var velocity = Vector2()
onready var target = self
onready var target_position = position
onready var anim_player = $AnimationPlayer
onready var dude_range = $Range
var item


func _physics_process(_delta):
	var flags = {}
	process_needs()
	if hunger < (max_hunger/2):
		eat()
	elif item:
		deposit_items()
	else:
		gather_items()
	if target_position:
		move()
	play_animation()


func process_needs():
	hunger -= 1
	if hunger <=0:
		queue_free()


func eat():
	var areas = dude_range.get_overlapping_areas()
	for area in areas:
		if area == target and area.is_in_group("food"):
			var food_value = area._gather()
			if food_value:
				hunger += food_value
				break
	var foods = get_tree().get_nodes_in_group("food")
	if foods:
		set_target(get_closest(foods))


func deposit_items():
	for area in dude_range.get_overlapping_areas():
		if area == target and area.is_in_group("depot"):
			area._deposit(item)
			item = null
			$BodySprite/ItemSprite.texture = item
			break
	var depots = get_tree().get_nodes_in_group("depot")
	if depots:
		set_target(depots[0])


func gather_items():
	var areas = dude_range.get_overlapping_areas()
	for area in areas:
		if area == target and area.is_in_group("resource"):
			item = area._gather()
			if item:
				var image_texture = ImageTexture.new()
				image_texture.create_from_image(load("res://assets/sprites/" + item + ".png"))
				image_texture.set_flags(Texture.FLAG_FILTER)
				$BodySprite/ItemSprite.texture = image_texture
				break
	var resources = get_tree().get_nodes_in_group("resource")
	if resources:
		set_target(get_closest(resources))


func move():
	if (target_position - position).length() > 30:
		velocity = (target_position - position).normalized() * speed
		velocity = move_and_slide(velocity)
	else:
		velocity = Vector2()
		target_position = null


func set_target(value):
	target = value
	target_position = target.global_position


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