extends Area2D

export (float) var offspring_padding = 5
export (int) var health = 50
var tree_scene = load("res://scenes/entities/tree.tscn")


func _ready():
	$SpawnTimer.connect("timeout", self, "_on_timer_timeout")


func _on_timer_timeout():
	var tree_instance = tree_scene.instance()
	var tree_width = $Sprite.texture.get_size().x
	var plant_dir = Vector2()
	var plant_spacing = tree_width * offspring_padding
	match randi()%4:
		0:
			plant_dir = Vector2(0, -plant_spacing)
		1:
			plant_dir = Vector2(-plant_spacing, 0)
		2:
			plant_dir = Vector2(0, plant_spacing)
		3:
			plant_dir = Vector2(plant_spacing, 0)
	
	tree_instance.position = position + plant_dir
	
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, tree_instance.position, [], 2147483647, false, true)
	
	if result.empty():
		get_parent().add_child(tree_instance)


func _gather():
	health -= 1
	if health == 0:
		queue_free()
		return "wood"
