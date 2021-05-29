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

var itemConfig = ConfigFile.new()

var playerConfig = ConfigFile.new()
	
var player = Array()

var playerCount = 0

func _ready():
	viewport2.world_2d = viewport1.world_2d
	camera1.target = world.get_node("Player1")
	camera2.target = world.get_node("Player2")
	player.append(world.get_node("Player1"))
	player.append(world.get_node("Player2"))
	if(playerCount > 2):
		viewport3.world_2d = viewport1.world_2d
		camera3.target = world.get_node("Player3")
	player.append(world.get_node("Player3"))
	if(playerCount > 3):
		viewport4.world_2d = viewport1.world_2d
		camera4.target = world.get_node("Player4")
	player.append(world.get_node("Player4"))
	itemConfig.load("res://config/items.cfg")
	playerConfig.load("res://config/player.cfg")
	
	
func setupPlayer(number):
	playerCount = number
		
	
# caller is player id [1,2,3,4]
func call_action(type,caller):
	var affects = get_item_config(type, "affects")
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

func get_item_config(item, config):
	return itemConfig.get_value(item, config, -1)
	
func get_player_config(config):
	return playerConfig.get_value("player", config, -1)
