extends KinematicBody2D

export var id = 0

export var speed = 250

var velo = Vector2()

func get_input():
	velo = Vector2()
	if(Input.is_action_pressed('right_%s'%id)):
		velo.x += 1
	if(Input.is_action_pressed('left_%s'%id)):
		velo.x -= 1
	if(Input.is_action_pressed('up_%s'%id)):
		velo.y -= 1
	if(Input.is_action_pressed('down_%s'%id)):
		velo.y += 1
	velo = velo.normalized()*speed
	
	
func _physics_process(delta):
	get_input()
	velo = move_and_slide(velo)
		
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
