extends Control

var playerCount = 2
var winner = 1
var startPage

onready var winnerLabel = $"VBoxContainer/Panel2/VBoxContainer/winnerLabel"

func _ready():
	if !MenuBgmAudioPlayer.playing:
		MenuBgmAudioPlayer.play()
	startPage = load("res://StartPage.tscn").instance()
	winnerLabel.text = "Player " + str(winner)
	get_node("VBoxContainer/Panel2/HBoxContainer/HBoxContainer2/MarginContainer/btnExit").grab_focus()


func setPlayerCount(count):
	playerCount = count
	
func setWinner(playernumber):
	winner = playernumber
	
func _on_btnExit_pressed():
	get_node("/root").add_child(startPage)
	get_node("/root").remove_child(self)


