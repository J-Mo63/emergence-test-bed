extends StaticBody2D

var health = 80

func _gather():
	health -= 1
	if health == 0:
		queue_free()
		return "rock"