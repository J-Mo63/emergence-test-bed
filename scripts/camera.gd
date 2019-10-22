extends Camera2D

func _unhandled_input(event):
	if event is InputEventPanGesture:
		position = position + (event.delta * 30)
	if event is InputEventMagnifyGesture:
		zoom_at_point(1/event.factor, event.position)

func zoom_at_point(zoom_change, point):
	var new_zoom = zoom * zoom_change
	var new_pos = global_position + (-0.5 * get_viewport().size + point)*(zoom - new_zoom)
	if new_zoom.x < 5 and new_zoom.x > 0.1:
		zoom = new_zoom
		global_position = new_pos