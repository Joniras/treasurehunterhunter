extends Area2D

export var id = 0

var lastPressedLeft = 0;
var lastPressedRight = 0;
var lastPressedUp = 0;
var lastPressedDown = 0;
onready var game = get_node("/root/Map")
var speed = 4 # gets changed anyway during startup
var items = Array()

onready var ray = $RayCast2D
onready var tween = $Tween

var tile_size = 4;

# Stun
var stun_time_left = 0
var bomb_time_left = 0
var speed_time_left = 0

var pauseInput = false


var velo = Vector2()

func get_input():
	if pauseInput:
		return

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
			velo = Vector2.LEFT
			$Sprite.flip_h = true
		elif(lastPressedRight == lastPressed):
			velo = Vector2.RIGHT
			$Sprite.flip_h = false
		elif(lastPressedUp == lastPressed):
			velo = Vector2.UP
		elif(lastPressedDown == lastPressed):
			velo = Vector2.DOWN
		
	if(Input.is_action_just_pressed("action_%s"%id)):
		do_action()
	

func do_action():
	if(items.size()>0):
		game.call_action(items.pop_front(), id)
		game.refreshItemView(items.duplicate(), id)
func _physics_process(delta):
	get_input()
	
	if (bomb_time_left):
		bomb_time_left -= delta * 1000
		if (bomb_time_left <= 0):
			speed = game.get_config("player", "speed")
	
	if (stun_time_left > 0):
		stun_time_left -= delta * 1000
		if (stun_time_left <= 0):
			speed /= game.get_item_config("stun", "value")
			
	if (speed_time_left > 0):
		speed_time_left -= delta * 1000
		if (speed_time_left <= 0):
			speed /= game.get_item_config("speed", "value")
			
	if(velo.x != 0 || velo.y != 0): # only do tweening of any movement is available at all
		if(speed > 0 && OS.get_ticks_msec()-lastInput >= (1.0/speed as float)*1000):
			lastInput = OS.get_ticks_msec()
			move(velo)
		
		
		
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func get_action_called(type):
	print("Player "+str(id)+" got action called "+ type)
	if (type == "stun"):
		speed *= game.get_item_config(type, "value")
		stun_time_left += game.get_item_config(type, "duration")
	elif (type == "speed"):
		speed *= game.get_item_config(type, "value")
		speed_time_left *= game.get_item_config(type, "duration")
	elif (type == "bomb"):
		speed = 0
		bomb_time_left += game.get_item_config(type, "duration")
		

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func adjustPositionToGrid():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	newPos = position

func setup():
	speed = game.get_config("player","speed")
	
func move(dir):
	ray.cast_to = velo * tile_size
	ray.force_raycast_update()
	
	if !ray.is_colliding():
		move_tween(dir)
	elif "Item" in ray.get_collider().name:
		move_tween(dir)
		print("Player "+str(id)+" got item: "+ray.get_collider().type)
		add_item(ray.get_collider().type)
		game.remove_item(ray.get_collider().id)
	elif(ray.get_collider().name == "TreasureHunter"):
			game.round_end_won(id)
			

var newPos
var lastInput = OS.get_ticks_msec()


func add_item(type):
	items.push_front(ray.get_collider().type)
	if(items.size() > game.get_config("player","itemCount")):
		items.pop_back()
	game.refreshItemView(items.duplicate(), id)
	
func setPausePlayerInput(pauseInput):
	self.pauseInput = pauseInput
	
func move_tween(dir):
	newPos = newPos + dir * tile_size
	tween.interpolate_property(self, "position",
		position, newPos,
		(1.0/speed as float), Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		
	tween.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
