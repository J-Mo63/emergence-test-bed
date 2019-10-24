extends Sprite

export (int) var day_cycle = 5000
export (int) var night_cycle = 2000
var current_cycle = 0
var night = true

func _process(delta):
	if current_cycle == 0:
		night = not night
		self.visible = night
		if night:
			current_cycle = day_cycle
		else:
			current_cycle = night_cycle
	current_cycle = current_cycle - 1