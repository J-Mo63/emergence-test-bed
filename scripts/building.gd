extends Area2D

export (float) var expansion_padding = 6
export (int) var max_health = 5000
onready var day_night_cycle = get_node("/root/Node2D/DayNightCycle")
onready var health = max_health
var upgraded = false
var current_occupant = null
var mark_for_free = false
var free_permitted = false

func _physics_process(delta):
	if mark_for_free and free_permitted:
		queue_free()
	
	if not day_night_cycle.is_night and current_occupant:
		set_occupation(false, current_occupant)
		current_occupant = null
	
	if health <= 0:
		if current_occupant:
			set_occupation(false, current_occupant)
			current_occupant = null
		mark_for_free = true
	elif health < max_health/4:
		$Destruction2Sprite.visible = true
	elif health < max_health/2:
		$Destruction1Sprite.visible = true
	else:
		$Destruction2Sprite.visible = false
		$Destruction1Sprite.visible = false
	
	health = health - 1

func _enter(dude):
	current_occupant = dude
	set_occupation(true, dude)

func set_occupation(occupied, occupant):
	occupant.visible = not occupied
	occupant.set_process(not occupied)
	occupant.set_physics_process(not occupied)
	$Lights.visible = occupied

func spawn_dude():
	var new_dude = load("res://scenes/entities/dude.tscn").instance()
	new_dude.position = position
	get_parent().add_child(new_dude)

func _fix():
	health = max_health

func needs_fix():
	return health < max_health/2

func _upgrade():
	upgraded = true
	$StoneSprite.visible = true
	$WoodSprite.visible = false
	var timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", self, "spawn_dude")
	timer.set_wait_time(1)
	timer.start()
	add_child(timer)

func _expand():
	var building_scene = load("res://scenes/entities/building.tscn")
	var new_building = building_scene.instance()
	new_building.position = position
	var building_width = $WoodSprite.texture.get_size().x
	var building_height = $WoodSprite.texture.get_size().y
	var building_spacing_h = building_width * expansion_padding
	var building_spacing_v = building_height * expansion_padding
	
	var build_directions = [Vector2(building_spacing_h, 0), Vector2(-building_spacing_h, 0), Vector2(0, building_spacing_v), Vector2(0, -building_spacing_v)]
	
	for direction in build_directions:
		new_building.position = position + direction
		
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, new_building.position, [self], collision_mask, true, true)
		
		if result.empty():
			get_parent().add_child(new_building)
			return new_building