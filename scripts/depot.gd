extends Area2D

export var upgrade_level = 100
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
	item_sprite.add_to_group("resource_sprite")
	add_child(item_sprite)


func _gather():
	depot_level += 1
	if depot_level >= upgrade_level:
		items["wood"] = items.get("wood") - 5
		$Sprite.visible = true
		
		var removed = 0
		for child in get_children():
			if child is Sprite and child.is_in_group("resource_sprite"):
				child.queue_free()
				removed += 1
				if removed >= 5:
					break
		queue_free()
		return true
	return false


func full():
	if depot_level < upgrade_level:
		return items.get("wood") and items.get("wood") >= 5
		