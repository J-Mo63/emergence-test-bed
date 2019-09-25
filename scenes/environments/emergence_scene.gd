extends Node2D

onready var food_timer = $FoodTimer
onready var food_scene = load("res://scenes/entities/food.tscn")


func _ready():
	food_timer.connect("timeout", self, "_generate_food")


func _generate_food():
	var food  = food_scene.instance()
	food.position = get_random_screen_location()
	add_child(food)


func get_random_screen_location():
	var rand_x = rand_range(0, get_viewport().size.x + 1)
	var rand_y = rand_range(0, get_viewport().size.y + 1)
	return Vector2(rand_x, rand_y)
