extends Node

# global states
const STATE_SHOW_CONTROLS = 0
const STATE_COUNTDOWN = 1
const STATE_PLAYING = 2
var current_global_state = STATE_SHOW_CONTROLS

onready var viewport1 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer1/Viewport1"
onready var controls_1 = $"Container/ViewportContainer/HBoxContainerTop/ControlsPanelContainer1"
onready var viewport3 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer3/Viewport3"
onready var controls_3 = $"Container/ViewportContainer/HBoxContainerTop/ControlsPanelContainer3"
onready var viewport2 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer2/Viewport2"
onready var controls_2 = $"Container/ViewportContainer/HBoxContainerBottom/ControlsPanelContainer2"
onready var viewport4 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer4/Viewport4"
onready var controls_4 = $"Container/ViewportContainer/HBoxContainerBottom/ControlsPanelContainer4"

onready var camera1 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer1/Viewport1/Camera2D"
onready var camera3 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer3/Viewport3/Camera2D"
onready var camera2 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer2/Viewport2/Camera2D"
onready var camera4 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer4/Viewport4/Camera2D"
onready var world = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer1/Viewport1/World"

var player = Array()

onready var controls_viewports = [controls_1, controls_2, controls_3, controls_4]
onready var camera_viewports = [viewport1, viewport2, viewport3, viewport4]
#var countdown_viewports = [] -> to be defined

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
	
	change_state(STATE_SHOW_CONTROLS)
	
func setupPlayer(number):
	playerCount = number
		
	
func call_action(type,caller):
	print(type)
	print(caller)

func call_all_other(type, caller):
	pass
	
func change_state(new_state):
	match(new_state):
		STATE_SHOW_CONTROLS:
			#hide_view_ports(camera_viewports)
			#show_view_ports(controls_viewports)
			load_control_schemes() #TODO: maybe do this in _ready()?
			
		STATE_PLAYING:
			hide_view_ports(controls_viewports)
			show_view_ports(camera_viewports)
			

# hides all passed viewports
func hide_view_ports(viewports_to_hide):
	for viewport in viewports_to_hide:
		viewport.visible = false
		
# shows all passed viewports
func show_view_ports(viewports_to_hide):
	for viewport in viewports_to_hide:
		viewport.visible = false

func load_control_schemes():
	# setup control screen for each player
	var player_id = 1
	
	for controls_node in controls_viewports:
		var controls_array = get_controls_for_player(player_id)
		controls_node.lblInput.text = get_controls_as_string(controls_array)
		player_id += 1
		
func get_controls_for_player(player_id):
	return [InputMap.get_action_list("up_%s"%player_id), InputMap.get_action_list("left_%s"%player_id),
	InputMap.get_action_list("down_%s"%player_id), InputMap.get_action_list("right_%s"%player_id),
	InputMap.get_action_list("action_%s"%player_id)]

func get_controls_as_string(controls_array):
	return "MOVEMENT: " + controls_array[0] + " " + controls_array[1] + " " + controls_array[2] + " " + controls_array[3] + "\nACTION: " + controls_array[4]
