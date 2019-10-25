extends KinematicBody2D

# Public fields
export (int) var speed = 100
export (int) var max_hunger = 3000
export (int) var lifespan = 10000

# Private fields
enum States {NO_FOOD}
var hunger = max_hunger
var velocity = Vector2()
onready var target = self
onready var target_position = position
onready var anim_player = $AnimationPlayer
onready var dude_range = $Range
onready var day_night_cycle = get_node("/root/Node2D/DayNightCycle")
var item
var has_building = false
var has_upgrade = false
var owned_depot
var owned_building


func _physics_process(_delta):
	process_needs()
	run_actions()
	move()
	play_animation()


func run_actions(flags = []):
	if owned_building and day_night_cycle.is_night:
		go_home()
	else:
		visible = true
		if hunger < (max_hunger/2) and not flags.has(States.NO_FOOD):
			eat()
		elif has_upgrade:
			upgrade_building()
		elif has_building:
			create_building()
		elif item:
			if owned_depot:
				deposit_items()
			else:
				create_depot()
		elif owned_depot and owned_depot.full_rock():
			gather_depot_rock()
		elif owned_depot and owned_depot.full_wood():
			gather_depot_wood()
		elif owned_building and not owned_building.upgraded:
			gather_items("quarry")
		else:
			gather_items("tree")


func process_needs():
	hunger -= 1
	lifespan -= 1
	if hunger <= 0 or lifespan <= 0:
		queue_free()


func eat():
	var food = get_target_area("food")
	if food:
		var food_value = food._gather()
		if food_value:
			hunger += food_value
	else:
		var foods = get_tree().get_nodes_in_group("food")
		if foods:
			set_target(get_closest(foods))
		else:
			run_actions([States.NO_FOOD])


func go_home():
	set_target(owned_building)


func create_building():
	var buildings = get_tree().get_nodes_in_group("building")
	var building = get_target_area("building")
	if building:
		owned_building = building._expand(self)
		has_building = false
	elif buildings.empty():
		var building_scene = preload("res://scenes/entities/building.tscn")
		var new_building = building_scene.instance()
		new_building.position = position
		get_parent().add_child(new_building)
		has_building = false
		owned_building = new_building
	elif buildings:
		set_target(get_closest(buildings))


func upgrade_building():
	var building = get_target_area("building")
	if building and building == owned_building:
		building._upgrade()
		has_upgrade = false
	else:
		set_target(owned_building)


func create_depot():
	var depot_scene = preload("res://scenes/entities/depot.tscn")
	owned_depot = depot_scene.instance()
	owned_depot.position = position
	get_parent().add_child(owned_depot)


func deposit_items():
	var depot = get_target_area("depot")
	if depot:
		depot._deposit(item)
		item = null
		$BodySprite/ItemSprite.texture = item
	else:
		set_target(owned_depot)


func gather_depot_wood():
	var depot = get_target_area("depot")
	if depot:
		if depot._gather_wood():
			has_building = true
			owned_depot = null
			var reporter = Reporter.new()
			reporter.report_event("boy howdy")
	else:
		set_target(owned_depot)


func gather_depot_rock():
	var depot = get_target_area("depot")
	if depot:
		if depot._gather_rock():
			has_upgrade = true
			owned_depot = null
	else:
		set_target(owned_depot)


func gather_items(type):
	var resource = get_target_area(type)
	if resource:
		item = resource._gather()
		if item:
			var image_texture = ImageTexture.new()
			image_texture.create_from_image(load("res://assets/sprites/" + item + ".png"))
			image_texture.set_flags(Texture.FLAG_FILTER)
			$BodySprite/ItemSprite.texture = image_texture
	else:
		var resources = get_tree().get_nodes_in_group(type)
		if resources:
			set_target(get_closest(resources))


func get_target_area(group_name):
	var areas = dude_range.get_overlapping_areas()
	for i in range(areas.size()):
		var area = areas[i]
		if area == target and area.is_in_group(group_name):
			return area


func move():
	if target_position:
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