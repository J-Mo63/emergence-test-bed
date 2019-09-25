extends Timer

onready var food_scene = load("res://scenes/entities/food.tscn")


func _ready():
	self.connect("timeout", self, "_generate_food")


func get_random_screen_location():
	var rand_x = rand_range(0, get_viewport().size.x + 1)
	var rand_y = rand_range(0, get_viewport().size.y + 1)
	return Vector2(rand_x, rand_y)


func _generate_food():
	var food  = food_scene.instance()
	food.position = get_random_screen_location()
	get_parent().add_child(food)
