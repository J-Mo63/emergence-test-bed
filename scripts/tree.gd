extends StaticBody2D

export var offspring_range = 50
var tree_scene = load("res://scenes/entities/tree.tscn")

func _ready():
	$Timer.connect("timeout", self, "_on_timer_timeout")


func _on_timer_timeout():
	var tree_instance = tree_scene.instance()
	var pos_x = rand_range(position.x - offspring_range, position.x + offspring_range)
	var pos_y = rand_range(position.y - offspring_range, position.y + offspring_range)
	
	tree_instance.position = Vector2(pos_x, pos_y)
	get_node("/root").add_child(tree_instance)