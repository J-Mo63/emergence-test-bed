extends Node

var game_event_file_name = "user://game_event_report.csv"
var game_param_file_name = "user://game_param_report.csv"
var current_line = 1
var max_runtime = 5
var game_params = []

onready var start_time = OS.get_ticks_msec()

func _physics_process(_delta):
	if get_time_msec() / 60000 >= max_runtime:
		get_tree().quit()
	
	if get_time_msec() % 10 == 0:
		report_params()

func _init():
	var file = File.new()
	
	# Create game event report
	file.open(game_event_file_name, File.WRITE)
	file.close()
	append_to_file(game_event_file_name, PoolStringArray([
		"id", 
		"time", 
		"entity_type", 
		"entity_id", 
		"pos_x",
		"pos_y",
		"event_type", 
	]))
	
	# Create game param report
	file.open(game_param_file_name, File.WRITE)
	file.close()
	append_to_file(game_param_file_name, PoolStringArray([
		# Markers
		"time",
		"is_night",
		# Params
		"tree_spawn_rate",
		"tree_health",
		"food_spawn_rate",
		"food_health",
		"plant_growth_rate",
		"dude_speed",
		"dude_max_hunger",
		"dude_lifespan",
		"wraith_speed",
		"quarry_health",
		"building_max_health",
		# Summary Stats
		"tree_population", 
		"dude_population", 
		"food_population", 
		"plant_population", 
		"building_population", 
	]))

func _ready():
	# Import scripts for checking properties
	var tree_script = preload("res://scripts/tree.gd").new()
	var food_script = preload("res://scripts/food.gd").new()
	var dude_script = preload("res://scripts/dude.gd").new()
	var wraith_script = preload("res://scripts/wraith.gd").new()
	var quarry_script = preload("res://scripts/quarry.gd").new()
	var building_script = preload("res://scripts/building.gd").new()
	# Set game params for session
	game_params = [
		get_node_property("wait_time", preload("res://scenes/entities/tree.tscn")),
		tree_script.health,
		get_node_property("wait_time", preload("res://scenes/entities/food.tscn")),
		food_script.health,
		get_node_property("wait_time", preload("res://scenes/entities/plant.tscn")),
		dude_script.speed,
		dude_script.max_hunger,
		dude_script.lifespan,
		wraith_script.speed,
		quarry_script.health,
		building_script.max_health
	]

func report_params():
	var line = PoolStringArray([
		get_time_msec(), 
		get_tree().root.get_node("Node2D/DayNightCycle").is_night
		] + game_params + [
		get_population("tree"), 
		get_population("dude"), 
		get_population("food"), 
		get_population("plant"), 
		get_population("building"),
	])
	append_to_file(game_param_file_name, line)

func report_event(entity, entity_type, event_details):
	var line = PoolStringArray([
		current_line, 
		get_time_msec(), 
		entity_type, 
		entity.get_instance_id(), 
		entity.global_position.x,
		entity.global_position.y,
		event_details, 
	])
	append_to_file(game_event_file_name, line)
	current_line += 1

func append_to_file(file_name, line):
	var file = File.new()
	file.open(file_name, File.READ_WRITE)
	file.seek_end()
	file.store_csv_line(line)
	file.close()

func get_time_msec():
	return OS.get_ticks_msec() - start_time

func get_population(group):
	return get_tree().get_nodes_in_group(group).size()

func get_node_property(property, packed_scene):
	var state = packed_scene.get_state()
	for idx in range(0, state.get_node_count()):
		for propIdx in range(0, state.get_node_property_count(idx) ):
			if state.get_node_property_name(idx, propIdx) == property:
				return state.get_node_property_value(idx, propIdx)