extends Camera2D

func _unhandled_input(event):
	print(event)
	if event is InputEventPanGesture:
		position = position + (event.delta * 30)
	if event is InputEventMagnifyGesture:
		zoom = zoom / event.factor