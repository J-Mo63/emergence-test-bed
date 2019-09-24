extends Area2D

export var offspring_padding = 3
var tree_scene = load("res://scenes/entities/tree.tscn")
var health = 50

func _ready():
	$Timer.connect("timeout", self, "_on_timer_timeout")
	pass


func _on_timer_timeout():
	var tree_instance = tree_scene.instance()
	var tree_width = $Sprite.texture.get_size().x / 6
	var angle = rand_range(0, 361)
	var new_dir = Vector2(cos(angle), sin(angle))
	
	tree_instance.position = position + new_dir * tree_width * offspring_padding
	
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, tree_instance.position)
	
	if !result:
		get_parent().add_child(tree_instance)


func _gather():
	health -= 1
	if health == 0:
		queue_free()
		return "wood"