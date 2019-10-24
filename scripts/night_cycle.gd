extends Sprite

export (int) var day_cycle = 5000
export (int) var night_cycle = 2000
var current_cycle = 0
var is_night = true

func _process(delta):
	if current_cycle == 0:
		is_night = not is_night
		self.visible = is_night
		if is_night:
			current_cycle = night_cycle
		else:
			current_cycle = day_cycle
	current_cycle = current_cycle - 1