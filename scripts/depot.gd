extends Area2D

export var max_health = 100
export var item_scatter = 30
onready var health = max_health
var mark_for_free = false
var items = {}

func _deposit(item):
	print("deposit contents: " + str(items))
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
	health -= 1
	if health <= 0:
		items["wood"] = items.get("wood") - amount
		var removed = 0
		for child in get_children():
			if child is Sprite and child.is_in_group("resource_sprite_wood"):
				child.queue_free()
				removed += 1
				if removed >= amount:
					break
		if empty():
			mark_for_free = true
			return "gone"
		health = max_health
		return "not gone"

func _gather_rock(amount):
	health -= 1
	if health <= 0:
		items["rock"] = items.get("rock") - amount
		var removed = 0
		for child in get_children():
			if child is Sprite and child.is_in_group("resource_sprite_rock"):
				child.queue_free()
				removed += 1
				if removed >= amount:
					break
		if empty():
			mark_for_free = true
			return "gone"
		health = max_health
		return "not gone"

func empty():
	for amount in items.values():
		if amount > 0:
			return false
	return true

func full_wood(amount):
	return items.get("wood") and items.get("wood") >= amount

func full_rock(amount):
	return items.get("rock") and items.get("rock") >= amount