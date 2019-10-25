extends Area2D

export (float) var offspring_padding = 5
export (int) var health = 50
var tree_scene = load("res://scenes/entities/tree.tscn")


func _ready():
	$SpawnTimer.connect("timeout", self, "_on_timer_timeout")


func _on_timer_timeout():
	var tree_instance = tree_scene.instance()
	var tree_width = $Sprite.texture.get_size().x
	var tree_height = $Sprite.texture.get_size().y
	var plant_dir = Vector2()
	var plant_spacing_x = tree_width * offspring_padding
	var plant_spacing_y = tree_height * offspring_padding
	match randi()%4:
		0:
			plant_dir = Vector2(0, -plant_spacing_y)
		1:
			plant_dir = Vector2(-plant_spacing_x, 0)
		2:
			plant_dir = Vector2(0, plant_spacing_y)
		3:
			plant_dir = Vector2(plant_spacing_x, 0)
	
	tree_instance.position = position + plant_dir
	
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, tree_instance.position, [self], 2147483647, true, true)
	
	if result.empty():
		get_parent().add_child(tree_instance)


func _gather():
	health -= 1
	if health == 0:
		queue_free()
		return "wood"
