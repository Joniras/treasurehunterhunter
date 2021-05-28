extends Node



onready var viewport1 = $VBoxContainer/HBoxContainer/ViewportContainer1/Viewport1
onready var viewport3 = $VBoxContainer/HBoxContainer/ViewportContainer3/Viewport3
onready var viewport2 = $VBoxContainer/HBoxContainer2/ViewportContainer2/Viewport2
onready var viewport4 = $VBoxContainer/HBoxContainer2/ViewportContainer4/Viewport4

onready var camera1 = $VBoxContainer/HBoxContainer/ViewportContainer1/Viewport1/Camera2D
onready var camera3 = $VBoxContainer/HBoxContainer/ViewportContainer3/Viewport3/Camera2D
onready var camera2 = $VBoxContainer/HBoxContainer2/ViewportContainer2/Viewport2/Camera2D
onready var camera4 = $VBoxContainer/HBoxContainer2/ViewportContainer4/Viewport4/Camera2D
onready var world = $VBoxContainer/HBoxContainer/ViewportContainer1/Viewport1/World

var playerNumber = 0

func _ready():
	viewport2.world_2d = viewport1.world_2d
	camera1.target = world.get_node("Player1")
	camera2.target = world.get_node("Player2")
	if(playerNumber > 2):
		viewport3.world_2d = viewport1.world_2d
		camera3.target = world.get_node("Player3")
	if(playerNumber > 3):
		viewport4.world_2d = viewport1.world_2d
		camera4.target = world.get_node("Player4")
	
	
func setupPlayer(number):
	playerNumber = number
		
	
