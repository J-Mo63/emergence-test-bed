extends Area2D

var health = 20

func _gather():
	health -= 1
	if health == 0:
		queue_free()
		return 1000