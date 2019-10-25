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
	item_sprite.scale = Vector2(5, 5)
	item_sprite.position = Vector2(rand_range(-item_scatter, item_scatter), rand_range(-item_scatter, item_scatter))
	item_sprite.add_to_group("resource_sprite_" + item)
	add_child(item_sprite)


func _gather_wood(amount):
	depot_level += 1
	if depot_level >= upgrade_level:
		items["wood"] = items.get("wood") - amount
		$Sprite.visible = true
		
		var removed = 0
		for child in get_children():
			if child is Sprite and child.is_in_group("resource_sprite_wood"):
				child.queue_free()
				removed += 1
				if removed >= amount:
					break
		queue_free()
		return true
	return false

func _gather_rock(amount):
	depot_level += 1
	if depot_level >= upgrade_level:
		items["rock"] = items.get("rock") - amount
		$Sprite.visible = true
		
		var removed = 0
		for child in get_children():
			if child is Sprite and child.is_in_group("resource_sprite_rock"):
				child.queue_free()
				removed += 1
				if removed >= amount:
					break
		queue_free()
		return true
	return false

func full_wood(amount):
	if depot_level < upgrade_level:
		return items.get("wood") and items.get("wood") >= amount

func full_rock(amount):
	if depot_level < upgrade_level:
		return items.get("rock") and items.get("rock") >= amount