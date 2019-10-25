extends Area2D

export (float) var expansion_padding = 6
export (int) var max_health = 5000
onready var day_night_cycle = get_node("/root/Node2D/DayNightCycle")
onready var health = max_health
var upgraded = false

func _physics_process(delta):
	#if day_night_cycle.is_night and overlaps_body(owning_dude):
			#set_occupation(true)
		#else:
			#set_occupation(false)
	if health <= 0:
		queue_free()
	elif health < max_health/4:
		$Destruction2Sprite.visible = true
	elif health < max_health/2:
		$Destruction1Sprite.visible = true
	health = health - 1

#func set_occupation(occupied):
	#owning_dude.visible = not occupied
	#owning_dude.set_process(not occupied)
	#owning_dude.set_physics_process(not occupied)
	#$Lights.visible = occupied

func spawn_dude():
	var new_dude = load("res://scenes/entities/dude.tscn").instance()
	new_dude.position = position
	get_parent().add_child(new_dude)

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

func _expand(owner_dude):
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
		var result = space_state.intersect_ray(position, new_building.position, [self], 2147483647, true, true)
		
		if result.empty():
			get_parent().add_child(new_building)
			return new_building