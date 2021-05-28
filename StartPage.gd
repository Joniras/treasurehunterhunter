extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var game = preload("res://SplitScreen/Map.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("VBoxContainer/Panel2/HBoxContainer2/optionsNumOfPlayers").grab_focus()


func start_game(numberPlayers):
	
	game.setupPlayer(numberPlayers)
	get_node("/root").add_child(game)
	get_node("/root").remove_child(self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
		if Input.is_action_pressed("ui_cancel"):
			get_tree().quit()
		
