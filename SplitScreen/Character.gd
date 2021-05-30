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

# items
const STUN = "stun"
const SPEED = "speed"
const WALL = "wall"
const SLOW = "slow"
const LIGHT = "light"
#const STUN = "stun"
var slow_time_left = 0
var stun_time_left = 0
var speed_time_left = 0
var light_time_left = 0
var slow_count_active = 0
var speed_count_active = 0
var light_count_active = 0


var label_time_left = 0

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
	
	if (stun_time_left > 0):
		stun_time_left -= delta * 1000
		if (stun_time_left <= 0):
			speed = game.get_config("speed")
			if slow_count_active> 0:
				speed = speed * game.get_item_config(SLOW, "value") * slow_count_active
			if speed_count_active > 0:
				speed = speed * game.get_item_config(SPEED, "value") * speed_count_active
			
	
	if (slow_count_active > 0):
		slow_time_left -= delta * 1000
		var slow_time_duration = game.get_item_config(SLOW, "duration")
		if (slow_time_left <= slow_time_duration * (slow_count_active - 1)):
			speed /= game.get_item_config(SLOW, "value")
			slow_count_active -= 1
			
	if (speed_count_active > 0):
		# print(str(speed_time_left))
		speed_time_left -= delta * 1000
		var speed_duration = game.get_item_config(SPEED, "duration")
		if (speed_time_left <= speed_duration * (speed_count_active - 1)):
			speed /= game.get_item_config(SPEED, "value")
			speed_count_active -= 1
			
	if (light_count_active > 0):
		light_time_left -= delta * 1000
		var light_duration = game.get_item_config(LIGHT, "duration")
		if (light_time_left <= light_duration * (light_count_active - 1)):
			$Light.set_texture_scale($Light.get_texture_scale() / game.get_item_config(LIGHT, "value"))
			light_count_active -= 1
			
	if(velo.x != 0 || velo.y != 0): # only do tweening of any movement is available at all
		if(speed > 0 && OS.get_ticks_msec()-lastInput >= (1.0/speed as float)*1000):
			lastInput = OS.get_ticks_msec()
			move(velo)
		
	
	if (label_time_left > 0):
		label_time_left -= delta * 1000
		if (label_time_left <= 0):
			hide_label()
		
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func get_action_called(type):
	# print("Player "+str(id)+" got action called "+ type)
	if (type == SLOW):
		speed *= game.get_item_config(type, "value")
		slow_time_left += game.get_item_config(type, "duration")
		slow_count_active += 1
		show_label("SLOWED")
	elif (type == SPEED):
		speed *= game.get_item_config(type, "value")
		speed_time_left += game.get_item_config(type, "duration")
		speed_count_active += 1
		show_label("SPEED UP")
	elif (type == STUN):
		speed = 0
		stun_time_left += game.get_item_config(type, "duration")
		show_label("STUNNED")
	elif (type == LIGHT):
		light_time_left += game.get_item_config(type, "duration")
		$Light.set_texture_scale($Light.get_texture_scale() * game.get_item_config(type, "value"))
		light_count_active += 1
		show_label("LIGHT++")
	elif (type == "path"):
		var betterPos = newPos
		betterPos.x -= (tile_size/2) 
		betterPos.y -= (tile_size/2) 
		betterPos = betterPos/tile_size
		game.showShortestPath(betterPos, id)
		show_label("H4CK")
	elif (type== "wall"):
		show_label("POW")

func show_label(text):
	$Label.visible = true
	$Label.text = text
	label_time_left = 1000
	
func hide_label():
	$Label.visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$"AnimationPlayer2".play("torch")

func adjustPositionToGrid():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	lastPressedLeft = 0
	lastPressedRight = 0
	lastPressedDown = 0
	lastPressedUp = 0
	newPos = position

func setup():
	speed = game.get_config("speed")
	
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
	if(items.size() > game.get_config("itemCount")):
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
