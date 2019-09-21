extends StaticBody2D

export var item_scatter = 30
var items = []

func _deposit(item):
	items.append(item)
	var item_sprite = Sprite.new()
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(load("res://assets/sprites/" + item + ".png"))
	image_texture.set_flags(Texture.FLAG_FILTER)
	item_sprite.texture = image_texture
	item_sprite.position = Vector2(rand_range(0, item_scatter), rand_range(0, item_scatter))
	add_child(item_sprite)
