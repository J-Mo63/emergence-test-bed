extends Area2D

func _ready():
	Reporter.report_event(self, "plant", "spawned")
	$Timer.connect("timeout", self, "grow")

func grow():
	var food = preload("res://scenes/entities/food.tscn").instance()
	food.position = position
	get_parent().add_child(food)
	queue_free()