extends Area2D

var health = 50

func _gather():
	health -= 1
	if health == 0:
		health = 80
		Reporter.report_event(self, "quarry", "harvested")
		return "rock"