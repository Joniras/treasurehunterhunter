extends Area2D

export var id = 0

var lastPressedLeft = 0;
var lastPressedRight = 0;
var lastPressedUp = 0;
var lastPressedDown = 0;
onready var game = get_node("/root/Map")
var speed = 250 # gets changed anyway during startup

onready var ray = $RayCast2D
onready var tween = $Tween

var tile_size = 4;

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
			speed = game.get_config("speed")
	if tween.is_active():
		return
	if(velo.x != 0 || velo.y != 0): # only do tweening of any movement is available at all
		move(velo)
		
		
	
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func get_action_called(type):
	print("Player "+str(id)+" got action called "+ type)
	if (type == "stun"):
		speed = 0
		stun_timeLeft += game.get_item_config(type, "duration")

# Called when the node enters the scene tree for the first time.
func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	
func setup():
	speed = game.get_config("speed")
	

func move(dir):
	ray.cast_to = velo * tile_size
	print(ray.cast_to)
	ray.force_raycast_update()
	if !ray.is_colliding():
		move_tween(dir)

func move_tween(dir):
	if(speed > 0):
		print("tweening")
		tween.interpolate_property(self, "position",
			position, position + dir * tile_size,
			1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
