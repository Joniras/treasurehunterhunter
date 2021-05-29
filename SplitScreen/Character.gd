extends KinematicBody2D

export var id = 0
export var speed = 250

var lastPressedLeft = 0;
var lastPressedRight = 0;
var lastPressedUp = 0;
var lastPressedDown = 0;
onready var game = get_node("/root/Map")

#### Items

# Stun
var stun_timeLeft = 0


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
	game.call_action(type, id)
	
func _physics_process(delta):
	get_input()
	
	if(stun_timeLeft > 0):
		stun_timeLeft -= delta*1000
		if(stun_timeLeft <= 0):
			speed = game.get_player_config("speed")
		
	velo = move_and_slide(velo)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func get_action_called(type):
	print(str(id)+" got action called "+ type)
	if (type == "stun"):
		speed = 0
		stun_timeLeft += game.get_item_config(type, "duration")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
