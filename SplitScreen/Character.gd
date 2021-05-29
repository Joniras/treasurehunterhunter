extends KinematicBody2D

export var id = 0
export var speed = 250

var lastPressedLeft = 0;
var lastPressedRight = 0;
var lastPressedUp = 0;
var lastPressedDown = 0;

var velo = Vector2()

func get_input():
	if(Input.is_action_just_pressed("left_%s"%id)):
		lastPressedLeft = OS.get_ticks_msec();
	if (Input.is_action_just_pressed('right_%s'%id)):
		lastPressedRight = OS.get_ticks_msec();
	if(Input.is_action_just_pressed('up_%s'%id)):
		lastPressedUp = OS.get_ticks_msec();
	if(Input.is_action_just_pressed('down_%s'%id)):
		lastPressedDown = OS.get_ticks_msec();
		
	if(Input.is_action_just_released("left_%s"%id)):
		lastPressedLeft = 0;
	if (Input.is_action_just_released('right_%s'%id)):
		lastPressedRight = 0;
	if(Input.is_action_just_released('up_%s'%id)):
		lastPressedUp = 0;
	if(Input.is_action_just_released('down_%s'%id)):
		lastPressedDown = 0;
		
	# get the last pressed button
	var lastPressed = max(lastPressedLeft, max(lastPressedRight, max(lastPressedUp, lastPressedDown)))
	velo = Vector2()
	if(lastPressed != 0):
		if(lastPressedLeft == lastPressed):
			velo.x -= 1
		if(lastPressedRight == lastPressed):
			velo.x += 1
		if(lastPressedUp == lastPressed):
			velo.y -= 1
		if(lastPressedDown == lastPressed):
			velo.y += 1
		
	velo = velo.normalized()*speed
	if(Input.is_action_just_pressed("action_%s"%id)):
		do_action()
	
	
func do_action():
	var type = "stun"
	get_node("/root/Map").call_action(type, id)
	
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
