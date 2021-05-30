extends Node

# global states
const STATE_SHOW_CONTROLS = 0
const STATE_PLAYING = 1
const STATE_BETWEEN_ROUNDS = 2
const STATE_GAME_END = 3

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

onready var player1 = world.get_node("Player1")
onready var player2 = world.get_node("Player2")
onready var player3 = world.get_node("Player3")
onready var player4 = world.get_node("Player4")

onready var topTimeLabel = $"Container/PanelTop/HBoxContainer/lblTimeGlobal"
onready var bottomTimeLabel = $"Container/PanelBottom/HBoxContainer/lblTimeGlobal"

onready var items1 = $"Container/PanelTop/HBoxContainer/HBoxContainer2/Player1ItemContainer"
onready var items2 = $"Container/PanelBottom/HBoxContainer/HBoxContainer/Player2ItemContainer"
onready var items3 = $"Container/PanelTop/HBoxContainer/HBoxContainer/Player3ItemContainer"
onready var items4 = $"Container/PanelBottom/HBoxContainer/HBoxContainer2/Player4ItemContainer"

onready var item = preload("res://items/ItemImage.tscn")

var config = ConfigFile.new()
var items = ConfigFile.new()

var remainingTime = 0
	
var player = Array()

onready var showControlsTimer = $"ShowControlsTimer"
var currentShowControlsTime = 10

onready var showScoresTimer = $"ShowScoresTimer"
var currentScoresTime = 5

onready var controls_labels = [controls_1, controls_2, controls_3, controls_4]
onready var controlContainers = [controlsContainer1, controlsContainer2, controlsContainer3, controlsContainer4]
onready var camera_viewports = [viewportContainer1, viewportContainer2, viewportContainer3, viewportContainer4]
#var countdown_viewports = [] -> to be defined

var colors = ["#D50000", "#2962FF", "#00C853", "#FFD600"]

var playerCount = 0

# index i = number of wins for player i+1
var numberOfWins = [0, 0, 0, 0]
var rng = RandomNumberGenerator.new()

# index of player which got the most points!
var winner = null

# used for countdown
const WAITING_TIMEOUT = 5
var nextRoundedInt = WAITING_TIMEOUT

signal roundOver(recreateMap)

func _ready():
	initDict()
	#stop all players
	MenuBgmAudioPlayer.stop()
	GameBgmAudioPlayer.stop()
	
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
	# set speed = 0, such that player is not movable in controls-view
	player1.speed = 0
	player2.setup()
	player2.speed = 0
	if(playerCount > 2):
		viewport3.world_2d = viewport1.world_2d
		camera3.target = player3
		player.append(player3)
		player3.setup()
		player3.speed = 0
		player3.get_node("Sprite").visible = true
	else:
		world.remove_child(player3)
		world.remove_child(player4)
	if(playerCount > 3):
		viewport4.world_2d = viewport1.world_2d
		camera4.target = player4
		player.append(player4)
		player4.setup()
		player4.speed = 0
		player4.get_node("Sprite").visible = true
	else:
		world.remove_child(player4)
	
	
	showControlsTimer.start()
	
	load_control_schemes()
	
	
func setupPlayer(number):
	playerCount = number

func round_end_time():
	emit_signal("roundOver", false)
	pausePlayerInput(true)
	change_state(STATE_BETWEEN_ROUNDS)

#is one of [1,2,3,4]
func round_end_won(playerWon):
	if current_global_state != STATE_PLAYING:
		return
	
	emit_signal("roundOver", true)
	pausePlayerInput(true)
	GameBgmAudioPlayer.stop()
	
	numberOfWins[playerWon - 1] += 1
	
	if numberOfWins[playerWon - 1] >= 3:
		winner = playerWon
		change_state(STATE_GAME_END)
	else:
		change_state(STATE_BETWEEN_ROUNDS)

func remove_item(id):
	for N in world.get_children():
		if("Item_"+str(id) in N.name):
			# print("Removed single Item: "+N.name)
			N.queue_free()

func refreshItemView(items, id):
	var itemBox
	var start = 1
	var increment = -0.2
	match id:
		1:
			itemBox = items1
			items.invert()
			increment = 0.2
			start = 1-(items.size()-1)*0.2
		2:
			itemBox = items2
		3:
			itemBox = items3
		4:
			itemBox = items4
			items.invert()
			increment = 0.2
			start = 1-(items.size()-1)*0.2
			
	for N in itemBox.get_children():
		itemBox.remove_child(N)
	var index = start
	for _item in items:
		var new_item = item.instance()
		new_item.texture = load("res://items/"+_item+"_item.png")
		new_item.set_modulate(Color(1,1,1,index))
		index += increment
		itemBox.add_child(new_item)
		pass

func _physics_process(delta):
	if (current_global_state == STATE_PLAYING):
		
		if(remainingTime>0):
			remainingTime-= delta
		if(remainingTime <= 0):
			round_end_time()
		else:
			display_time()

func start_round():
	remainingTime = get_config("roundTime")
	world.set_player_positions()

func _process(delta):	
	if current_global_state == STATE_SHOW_CONTROLS:
		currentShowControlsTime = round(showControlsTimer.time_left)
		
		if (!GameBgmAudioPlayer.playing && showControlsTimer.time_left <= 2):
			GameBgmAudioPlayer.play()
			
		if (showControlsTimer.time_left <= nextRoundedInt && nextRoundedInt >= 0):
			nextRoundedInt -= 1
			$"CountdownAudioPlayer".play()
			topTimeLabel.text = str(currentShowControlsTime)
			bottomTimeLabel.text = str(currentShowControlsTime)
		
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
	
	if current_global_state == STATE_BETWEEN_ROUNDS:
		
		if (!GameBgmAudioPlayer.playing && $"ShowScoresTimer".time_left <= 2):
			GameBgmAudioPlayer.play()
			
		if ($"ShowScoresTimer".time_left <= nextRoundedInt && nextRoundedInt >= 0):
			nextRoundedInt -= 1
			$"CountdownAudioPlayer".play()
			topTimeLabel.text = str(round($"ShowScoresTimer".time_left))
			bottomTimeLabel.text = str(round($"ShowScoresTimer".time_left))

func display_time():
	var timeString
	if(remainingTime > 10):
		timeString = str(remainingTime as int)
	else:
		timeString = str(floor(remainingTime *100)/100)
		topTimeLabel.add_color_override("font_color", Color(1,0,0))
		bottomTimeLabel.add_color_override("font_color", Color(1,0,0))
	
	topTimeLabel.text = timeString
	bottomTimeLabel.text = timeString
	
	
# caller is player id [1,2,3,4]
func call_action(type,caller):
	if current_global_state != STATE_PLAYING:
		return
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



func call_random_other(type, caller):
	var to = caller-1
	while(to == caller-1):
		to = rng.randi_range(0, playerCount-1)
	player[to].get_action_called(type)
	
	
func call_all(type):
	for _player in player:
		_player.get_action_called(type)

var gameConfig = Dictionary()


var itemConfig = Dictionary()

func initDict():
	gameConfig["speed"] = 5
	gameConfig["itemCount"] = 5
	gameConfig["roundTime"] = 60
	
	
	var slow = Dictionary()
	slow["duration"] = 4000
	slow["affects"] = "ALL_OTHER"
	slow["value"] = 0.5
	itemConfig["slow"] = slow
	
	var stun = Dictionary()
	stun["duration"] = 2000
	stun["affects"] = "RANDOM_OTHER"
	itemConfig["stun"] = stun
	
	var speed = Dictionary()
	speed["duration"] = 4000
	speed["affects"] = "SELF"
	speed["value"] = 2
	itemConfig["speed"] = speed
	 

func get_item_config(item, attribute):
	return itemConfig[item][attribute]
	
	
func get_config(attribute):
	return gameConfig[attribute]
	
	
func change_state(new_state):
	topTimeLabel.add_color_override("font_color", Color("#66545e"))
	bottomTimeLabel.add_color_override("font_color", Color("#66545e"))
	nextRoundedInt = WAITING_TIMEOUT
	current_global_state = new_state
	match(new_state):
		STATE_PLAYING:
			pausePlayerInput(false)
			var defaultPlayerSpeed = get_config("speed")
			player1.speed = defaultPlayerSpeed
			player2.speed = defaultPlayerSpeed
			if playerCount >= 3:
				player3.speed = defaultPlayerSpeed
			if playerCount >= 4:
				player4.speed = defaultPlayerSpeed
			
			hide_view_ports(controlContainers)
			show_view_ports(camera_viewports)
			start_round()
		STATE_BETWEEN_ROUNDS:
			player1.speed = 0
			player2.speed = 0
			if playerCount >= 3:
				player3.speed = 0
			if playerCount >= 4:
				player4.speed = 0
			
			hide_view_ports(camera_viewports)
			show_view_ports(controlContainers)
			# show labels indicating points
			var i = 0
			for label in controls_labels:
				label.text = "Wins: " + str(numberOfWins[i])
				i += 1
				
			# hide non-player containers
			if playerCount == 2:
				controlContainers[2].visible = false
				controlContainers[3].visible = false
				camera_viewports[2].visible = true
				camera_viewports[3].visible = true
				
			if playerCount == 3:
				controlContainers[3].visible = false
				camera_viewports[3].visible = true
				
			# wait until timer is over and return to STATE_PLAYING
			$"ShowScoresTimer".start(5)
			
		STATE_GAME_END:
			onGameOver()
			

# hides all passed viewports
func hide_view_ports(viewports_to_hide):
	for viewport in viewports_to_hide:
		viewport.visible = false
		
		
# shows all passed viewports
func show_view_ports(viewports_to_show):
	for viewport in viewports_to_show:
		viewport.visible = true

func pausePlayerInput(isPaused):
	for p in player:
		p.setPausePlayerInput(isPaused)

func load_control_schemes():
	# setup control screen for each player
	var player_id = 1
	while player_id <= playerCount:
		var controls_array = get_controls_for_player(player_id)
		controls_labels[player_id - 1].text = get_controls_as_string(controls_array)
		controlContainers[player_id - 1].visible = true
		
		player_id += 1
		
	# auskommentieren, wenn spieler wieder sortiert angezeigt werden sollen:
	if playerCount == 2:
		controlContainers[1].get_node("PlayerLabel").text = "Player 2"
		
	if playerCount == 3:
		controlContainers[1].get_node("PlayerLabel").text = "Player 2"
		controlContainers[2].get_node("PlayerLabel").text = "Player 3"
		
	if playerCount == 4:
		controlContainers[1].get_node("PlayerLabel").text = "Player 2"
		controlContainers[2].get_node("PlayerLabel").text = "Player 3"
		controlContainers[3].get_node("PlayerLabel").text = "Player 4"
		
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


func _on_ShowScoresTimer_timeout():
	change_state(STATE_PLAYING)


func _on_ShowControlsTimer_timeout():
	change_state(STATE_PLAYING)


func onGameOver():
	var gameOver = load("res://GameOver.tscn").instance()
	gameOver.setPlayerCount(playerCount)
	gameOver.setWinner(winner)
	get_node("/root").add_child(gameOver)
	get_node("/root").remove_child(self)
