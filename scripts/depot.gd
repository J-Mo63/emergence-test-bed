extends Area2D

export var item_scatter = 30
var items = {}
var depot_level = 0


func _deposit(item):
	if items.has(item):
		items[item] = items.get(item) + 1
	else:
		items[item] = 1
	var item_sprite = Sprite.new()
	var image_texture = ImageTexture.new()
	image_texture.create_from_image(load("res://assets/sprites/" + item + ".png"))
	image_texture.set_flags(Texture.FLAG_FILTER)
	item_sprite.texture = image_texture
	item_sprite.position = Vector2(rand_range(-item_scatter, item_scatter), rand_range(-item_scatter, item_scatter))
	add_child(item_sprite)


func _upgrade():
	depot_level += 1
	if depot_level >= 10:
		# make it clear
		pass


func upgradable():
	if depot_level < 10:
		if items.get("wood") and items.get("rock"):
			return items.get("wood") >= 1 and items.get("rock") >= 2