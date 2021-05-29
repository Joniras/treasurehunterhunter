extends Node


onready var viewport1 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer1/Viewport1"
onready var viewport3 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer3/Viewport3"
onready var viewport2 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer2/Viewport2"
onready var viewport4 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer4/Viewport4"

onready var camera1 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer1/Viewport1/Camera2D"
onready var camera3 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer3/Viewport3/Camera2D"
onready var camera2 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer2/Viewport2/Camera2D"
onready var camera4 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer4/Viewport4/Camera2D"
onready var world = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer1/Viewport1/World"

onready var player1 = world.get_node("Player1")
onready var player2 = world.get_node("Player2")
onready var player3 = world.get_node("Player3")
onready var player4 = world.get_node("Player4")

onready var topTimeLabel = $"Container/PanelTop/lblTimeGlobal"
onready var bottomTimeLabel = $"Container/PanelBottom/lblTimeGlobal"

var config = ConfigFile.new()
var items = ConfigFile.new()

var remainingTime = 0
	
var player = Array()

var playerCount = 0

func _ready():
	config.load("res://config/game.cfg")
	items.load("res://config/items.cfg")
	viewport2.world_2d = viewport1.world_2d
	camera1.target = player1
	player1.get_node("Sprite").visible = true
	camera2.target = player2
	player2.get_node("Sprite").visible = true
	player.append(player1)
	player.append(player2)
	player1.setup()
	player2.setup()
	if(playerCount > 2):
		viewport3.world_2d = viewport1.world_2d
		camera3.target = player3
		player.append(player3)
		player3.setup()
		player3.get_node("Sprite").visible = true
	else:
		world.remove_child(player3)
		world.remove_child(player4)
	if(playerCount > 3):
		viewport4.world_2d = viewport1.world_2d
		camera4.target = player4
		player.append(player4)
		player4.setup()
		player4.get_node("Sprite").visible = true
	else:
		world.remove_child(player4)
	start_round()
	
func setupPlayer(number):
	playerCount = number
		
func round_end_time():
	#TODO: call screen to go next round or won
	pass

#is one of [1,2,3,4]
func round_end_won(playerWon):
	pass

func _physics_process(delta):
	if(remainingTime>0):
		remainingTime-= delta
	if(remainingTime <= 0):
		round_end_time()
	else:
		display_time()
		
func start_round():
	remainingTime = get_config("game","roundTime")
	world.set_player_positions()
	
		
func display_time():
	var timeString
	if(remainingTime > 10):
		timeString = str(remainingTime as int)
	else:	
		timeString = str(floor(remainingTime *100)/100)
	
	topTimeLabel.text = timeString
	bottomTimeLabel.text = timeString
	
# caller is player id [1,2,3,4]
func call_action(type,caller):
	var affects = get_item_config(type, "affects")
	print(type +" affects: "+str(affects))
	match affects:
		"ALL_OTHER":
			call_all_other(type,caller)
		"RANDOM_OTHER":
			call_random_other(type,caller)
		"ALL":
			call_all(type)
		"RANDOM":
			call_random(type)
		"SELF":
			call_self(type, caller)

func call_all_other(type, caller):
	var index = 0
	for _player in player:
		index = index +1
		if(index != caller):
			_player.get_action_called(type)
			

func call_self(type, caller):
	player[caller-1].get_action_called(type)

func call_random(type):
	player[rng.randi_range(0, playerCount)].get_action_called(type)

var rng = RandomNumberGenerator.new()

func call_random_other(type, caller):
	var to = caller-1
	while(to == caller-1):
		to = rng.randi_range(0, playerCount)
	player[to].get_action_called(type)
	
	
func call_all(type):
	for _player in player:
		_player.get_action_called(type)

func get_item_config(item, attribute):
	return items.get_value(item, attribute, -1)
	
func get_config(section, attribute):
	var _config = config.get_value(section, attribute, -1)
	print("Got "+section+":"+attribute+" result: "+str(_config))
	return _config
