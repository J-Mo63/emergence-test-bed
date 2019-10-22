extends Area2D

export (float) var expansion_padding = 6

func _ready():
	var timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", self, "spawn_dude")
	timer.set_wait_time(1)
	timer.start()
	add_child(timer)

func spawn_dude():
	var new_dude = load("res://scenes/entities/dude.tscn").instance()
	new_dude.position = position
	get_parent().add_child(new_dude)

func _expand():
	var building_scene = load("res://scenes/entities/building.tscn")
	var new_building = building_scene.instance()
	new_building.position = position
	var building_width = $Sprite.texture.get_size().x
	var building_spacing_h = building_width * expansion_padding
	var building_spacing_v = building_width * (expansion_padding / 2)
	
	var build_directions = [Vector2(building_spacing_h, 0), Vector2(-building_spacing_h, 0), Vector2(0, building_spacing_v), Vector2(0, -building_spacing_v)]
	
	for direction in build_directions:
		new_building.position = position + direction
		
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(position, new_building.position, [self], 2147483647, false, true)
		
		if result.empty() or not result.collider.is_in_group("building"):
			get_parent().add_child(new_building)
			break