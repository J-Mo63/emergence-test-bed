extends KinematicBody2D

# Enums
enum States {NO_FOOD}
enum Building {UPGRADE, FIX, ENTER}

# Export fields
export (int) var speed = 100
export (int) var max_hunger = 5000
export (int) var lifespan = 10000

# Onready fields
onready var target = self
onready var target_position = position
onready var anim_player = $AnimationPlayer
onready var dude_range = $Range
onready var day_night_cycle = get_node("/root/Node2D/DayNightCycle")

# Misc fields
var velocity = Vector2()
var item
var hunger = max_hunger

# Ownership fields
var owned_depot
var owned_building

# Building fields
var has_building = false
var has_upgrade = false
var has_fix = false


func _ready():
	Reporter.report_event(self, "dude", "spawned")


func _physics_process(_delta):
	remove_dead_refs()
	process_needs()
	run_actions()
	move()
	play_animation()


func remove_dead_refs():
	if owned_depot and owned_depot.mark_for_free:
		owned_depot.free_permitted = true
		owned_depot = null
	if owned_building and owned_building.mark_for_free:
		owned_building.free_permitted = true
		owned_building = null


func drop_all_refs():
	if owned_depot:
		owned_depot.mark_for_free = true
		owned_depot.free_permitted = true
		owned_depot = null
	if owned_building:
		owned_building.free_permitted = true
		owned_building = null


func run_actions(flags = []):
	if hunger < (max_hunger/2) and not flags.has(States.NO_FOOD):
		eat()
	elif owned_building:
		if day_night_cycle.is_night:
			use_owned_building(Building.ENTER)
		elif owned_building.needs_fix():
			if has_fix:
				use_owned_building(Building.FIX)
			else:
				gather_resources(10, "wood", "tree")
		elif not owned_building.upgraded:
			if has_upgrade:
				use_owned_building(Building.UPGRADE)
			else:
				gather_resources(5, "rock", "quarry")
	elif has_building:
		create_building()
	else:
		gather_resources(5, "wood", "tree")


func process_needs():
	hunger -= 1
	lifespan -= 1
	if hunger <= 0 or lifespan <= 0:
		drop_all_refs()
		queue_free()
		Reporter.report_event(self, "dude", "died")


func eat():
	var food = get_target_area("food")
	if food:
		if food._gather():
			hunger = max_hunger
			Reporter.report_event(self, "dude", "ate_food")
	else:
		var foods = get_tree().get_nodes_in_group("food")
		if foods:
			set_target(get_closest(foods))
		else:
			run_actions([States.NO_FOOD])


func gather_resources(amount, resource, source):
	if item:
		if owned_depot:
			deposit_items()
		else:
			create_depot()
	elif owned_depot and owned_depot.has(amount, resource):
		gather_depot(resource, amount)
	else:
		gather_items(source)


func use_owned_building(interaction):
	var building = get_target_area("building")
	if building and building == owned_building:
		match interaction:
			Building.UPGRADE:
				building._upgrade()
				has_upgrade = false
				Reporter.report_event(self, "dude", "upgraded_building")
			Building.FIX:
				building._fix()
				has_fix = false
				Reporter.report_event(self, "dude", "fixed_building")
			Building.ENTER:
				building._enter(self)
				Reporter.report_event(self, "dude", "entered_building")
	else:
		set_target(owned_building)


func create_building():
	var buildings = get_tree().get_nodes_in_group("building")
	var building = get_target_area("building")
	if building:
		owned_building = building._expand()
		has_building = false
		Reporter.report_event(self, "dude", "spawned_building")
	elif buildings.empty():
		var building_scene = preload("res://scenes/entities/building.tscn")
		var new_building = building_scene.instance()
		new_building.position = position
		get_parent().add_child(new_building)
		has_building = false
		owned_building = new_building
		Reporter.report_event(self, "dude", "spawned_building")
	elif buildings:
		set_target(get_closest(buildings))


func create_depot():
	var depot_scene = preload("res://scenes/entities/depot.tscn")
	owned_depot = depot_scene.instance()
	owned_depot.position = position
	get_parent().add_child(owned_depot)
	Reporter.report_event(self, "dude", "spawned_depot")


func deposit_items():
	var depot = get_target_area("depot")
	if depot:
		depot._deposit(item)
		Reporter.report_event(self, "dude", "deposited_resource_" + item)
		item = null
		$BodySprite/ItemSprite.texture = item
	else:
		set_target(owned_depot)


func gather_depot(resource, amount):
	var depot = get_target_area("depot")
	if depot:
		var result = depot._gather(resource, amount)
		match result:
			"building":
				has_building = true
				Reporter.report_event(self, "dude", "gathered_building_materials")
			"upgrade":
				has_upgrade = true
				Reporter.report_event(self, "dude", "gathered_upgrade_materials")
			"fix":
				has_fix = true
				Reporter.report_event(self, "dude", "gathered_fix_materials")
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
			Reporter.report_event(self, "dude", "harvested_resource_" + type)
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