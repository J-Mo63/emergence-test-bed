extends KinematicBody2D

export (int) var speed = 100
var velocity = Vector2()
onready var anim = get_node("./AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(_delta):
	velocity = Vector2()
	if Input.is_action_pressed('right'):
		velocity.x += 1
		anim.play("walk_right")
	if Input.is_action_pressed('left'):
		velocity.x -= 1
		anim.play("walk_left")
	if Input.is_action_pressed('down'):
		velocity.y += 1
		anim.play("walk_down")
	if Input.is_action_pressed('up'):
		velocity.y -= 1
		anim.play("walk_up")
	velocity = velocity.normalized() * speed
	
	velocity = move_and_slide(velocity)
