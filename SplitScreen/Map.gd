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

var config = ConfigFile.new()
var items = ConfigFile.new()

	
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
	
	
func setupPlayer(number):
	playerCount = number
		
	
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
	
func get_config(attribute):
	var _config = config.get_value("player", attribute, -1)
	print("Got "+attribute+" result: "+str(_config))
	return _config
