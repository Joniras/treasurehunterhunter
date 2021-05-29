extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	get_node("VBoxContainer/Panel2/HBoxContainer2/optionsNumOfPlayers").grab_focus()
	if !MenuBgmAudioPlayer.playing:
		MenuBgmAudioPlayer.play()

func start_game(numberPlayers):
	var game = load("res://SplitScreen/Map.tscn").instance()
	game.setupPlayer(numberPlayers)
	get_node("/root").add_child(game)
	get_node("/root").remove_child(self)

func _input(event):
		if Input.is_action_pressed("ui_cancel"):
			get_tree().quit()
		if Input.is_action_just_pressed("left_mouse") || Input.is_action_just_pressed("ui_accept"):
			$mouse_AudioStreamPlayer.play()
