extends Area2D

export var max_health = 100
export var item_scatter = 30
onready var health = max_health
var mark_for_free = false
var free_permitted = false
var items = {}

func _physics_process(delta):
	if mark_for_free and free_permitted:
		queue_free()

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


func _gather(resource, amount):
	health -= 1
	if health <= 0:
		items[resource] = items.get(resource) - amount
		var removed = 0
		for child in get_children():
			if child is Sprite and child.is_in_group("resource_sprite_" + resource):
				child.queue_free()
				removed += 1
				if removed >= amount:
					break
		if empty():
			mark_for_free = true
		health = max_health
		if resource == "wood" and amount == 5:
			return "building"
		elif resource == "rock" and amount == 5:
			return "upgrade"
		elif resource == "wood" and amount == 10:
			return "fix"


func empty():
	for amount in items.values():
		if amount > 0:
			return false
	return true


func has(amount, resource):
	return items.get(resource) and items.get(resource) >= amount