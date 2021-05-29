extends Node

# global states
const STATE_SHOW_CONTROLS = 0
const STATE_PLAYING = 1
const STATE_BETWEEN_ROUNDS = 2
var current_global_state = STATE_SHOW_CONTROLS

onready var viewport1 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer1/Viewport1"
onready var viewportContainer1 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer1"
onready var controls_1 = $"Container/ViewportContainer/HBoxContainerTop/ControlsPanelContainer1/lblInput"
onready var controlsContainer1 = $"Container/ViewportContainer/HBoxContainerTop/ControlsPanelContainer1"
onready var viewport3 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer3/Viewport3"
onready var viewportContainer3 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer3"
onready var controls_3 = $"Container/ViewportContainer/HBoxContainerTop/ControlsPanelContainer3/lblInput"
onready var controlsContainer3 = $"Container/ViewportContainer/HBoxContainerTop/ControlsPanelContainer3"
onready var viewport2 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer2/Viewport2"
onready var viewportContainer2 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer2"
onready var controls_2 = $"Container/ViewportContainer/HBoxContainerBottom/ControlsPanelContainer2/lblInput"
onready var controlsContainer2 = $"Container/ViewportContainer/HBoxContainerBottom/ControlsPanelContainer2"
onready var viewport4 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer4/Viewport4"
onready var viewportContainer4 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer4"
onready var controls_4 = $"Container/ViewportContainer/HBoxContainerBottom/ControlsPanelContainer4/lblInput"
onready var controlsContainer4 = $"Container/ViewportContainer/HBoxContainerBottom/ControlsPanelContainer4"

onready var camera1 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer1/Viewport1/Camera2D"
onready var camera3 = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer3/Viewport3/Camera2D"
onready var camera2 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer2/Viewport2/Camera2D"
onready var camera4 = $"Container/ViewportContainer/HBoxContainerBottom/ViewportContainer4/Viewport4/Camera2D"
onready var world = $"Container/ViewportContainer/HBoxContainerTop/ViewportContainer1/Viewport1/World"


onready var showControlsTimer = $"ShowControlsTimer"
var currentTime = 10

var player = Array()

onready var controls_labels = [controls_1, controls_2, controls_3, controls_4]
onready var controlContainers = [controlsContainer1, controlsContainer2, controlsContainer3, controlsContainer4]
onready var camera_viewports = [viewportContainer1, viewportContainer2, viewportContainer3, viewportContainer4]
#var countdown_viewports = [] -> to be defined

var colors = ["#D50000", "#2962FF", "#00C853", "#FFD600"]

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
	
	load_control_schemes()
	
func _process(delta):
	if current_global_state == STATE_SHOW_CONTROLS:	
		currentTime = round(showControlsTimer.time_left)
		
		if (Input.is_action_pressed("up_1") || Input.is_action_pressed("down_1") || Input.is_action_pressed("left_1") || Input.is_action_pressed("right_1") || Input.is_action_pressed("action_1")):
			show_controls_border_for_player_id(1)
			
		if (Input.is_action_just_released("up_1") || Input.is_action_just_released("down_1") || Input.is_action_just_released("left_1") || Input.is_action_just_released("right_1") || Input.is_action_just_released("action_1")):
			hide_controls_border_for_player(1)
		
		if (Input.is_action_pressed("up_2") || Input.is_action_pressed("down_2") || Input.is_action_pressed("left_2") || Input.is_action_pressed("right_2") || Input.is_action_pressed("action_2")):
			show_controls_border_for_player_id(2)
			
		if (Input.is_action_just_released("up_2") || Input.is_action_just_released("down_2") || Input.is_action_just_released("left_2") || Input.is_action_just_released("right_2") || Input.is_action_just_released("action_2")):
			hide_controls_border_for_player(2)
			
		if (Input.is_action_pressed("up_3") || Input.is_action_pressed("down_3") || Input.is_action_pressed("left_3") || Input.is_action_pressed("right_3") || Input.is_action_pressed("action_3")):
			show_controls_border_for_player_id(3)
			
		if (Input.is_action_just_released("up_3") || Input.is_action_just_released("down_3") || Input.is_action_just_released("left_3") || Input.is_action_just_released("right_3") || Input.is_action_just_released("action_3")):
			hide_controls_border_for_player(3)
			
		if (Input.is_action_pressed("up_4") || Input.is_action_pressed("down_4") || Input.is_action_pressed("left_4") || Input.is_action_pressed("right_4") || Input.is_action_pressed("action_4")):
			show_controls_border_for_player_id(4)
			
		if (Input.is_action_just_released("up_4") || Input.is_action_just_released("down_4") || Input.is_action_just_released("left_4") || Input.is_action_just_released("right_4") || Input.is_action_just_released("action_4")):
			hide_controls_border_for_player(4)
			
	$"Container/PanelTop/lblTimeGlobal".text = str(currentTime)
	$"Container/PanelBottom/lblTimeGlobal".text = str(currentTime)
	

func setupPlayer(number):
	playerCount = number
	
func call_action(type,caller):
	print(type)
	print(caller)

func call_all_other(type, caller):
	pass
	
func change_state(new_state):
	match(new_state):
		STATE_PLAYING:
			hide_view_ports(controlContainers)
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
	while player_id <= playerCount:
		var controls_array = get_controls_for_player(player_id)
		controls_labels[player_id - 1].text = get_controls_as_string(controls_array)
		controlContainers[player_id - 1].visible = true
		
		player_id += 1
		
	if playerCount == 2:
		controlContainers[1].get_node("PlayerLabel").text = "Player 2"
		
	if playerCount == 3:
		controlContainers[1].get_node("PlayerLabel").text = "Player 3"
		controlContainers[2].get_node("PlayerLabel").text = "Player 2"
		
	while player_id <= 4:
		camera_viewports[player_id - 1].visible = true
		player_id += 1
		
func get_controls_for_player(player_id):
	var key_up = "W"
	var key_down = "S"
	var key_left = "A"
	var key_right = "D"
	var key_action = "E"
	
	match player_id:
		2:  
			key_up = "UP"
			key_down = "DOWN"
			key_left = "LEFT"
			key_right = "RIGHT"
			key_action = "CTRL"
			
		3:  
			key_up = "8"
			key_down = "5"
			key_left = "4"
			key_right = "6"
			key_action = "9"
			
		4:  
			key_up = "I"
			key_down = "K"
			key_left = "J"
			key_right = "L"
			key_action = "O"
	
	return [key_up, key_left, key_down, key_right, key_action]

func get_controls_as_string(controls_array):
	return "MOVEMENT: " + controls_array[0] + " " + controls_array[1] + " " + controls_array[2] + " " + controls_array[3] + "\nACTION: " + controls_array[4]

func _on_ShowControlsTimer_timeout():
	change_state(STATE_PLAYING)
	
func show_controls_border_for_player_id(player_id):
	var panelNode = controls_labels[player_id - 1].get_parent().get_node("Panel")
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color("#66545e")
	new_style.set_border_color(colors[player_id - 1])
	new_style.set_border_width_all(8)
	panelNode.set('custom_styles/panel', new_style)

func hide_controls_border_for_player(player_id):
	var panelNode = controls_labels[player_id - 1].get_parent().get_node("Panel")
	var new_style = StyleBoxFlat.new()
	new_style.set_bg_color("#66545e")
	new_style.set_border_width_all(0)
	panelNode.set('custom_styles/panel', new_style)
