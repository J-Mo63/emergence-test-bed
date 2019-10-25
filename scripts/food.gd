extends Area2D

export (float) var offspring_padding = 15
var health = 20

func _ready():
	$Timer.connect("timeout", self, "spawn")

func _gather():
	health -= 1
	if health == 0:
		queue_free()
		return true

func spawn():
	var plant_instance = load("res://scenes/entities/plant.tscn").instance()
	var food_width = $Sprite.texture.get_size().x
	var plant_spacing = food_width * offspring_padding
	var plant_dir
	match randi()%4:
		0:
			plant_dir = Vector2(0, -plant_spacing)
		1:
			plant_dir = Vector2(-plant_spacing, 0)
		2:
			plant_dir = Vector2(0, plant_spacing)
		3:
			plant_dir = Vector2(plant_spacing, 0)
	
	plant_instance.position = position + plant_dir
	
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, plant_instance.position, [], 2147483647, false, true)
	
	if result.empty():
		get_parent().add_child(plant_instance)