extends Control

var playerCount = 2
var winner = 1
var startPage

onready var winnerLabel = $"VBoxContainer/Panel2/VBoxContainer/winnerLabel"

func _ready():
	startPage = load("res://StartPage.tscn").instance()
	winnerLabel.text = "Player " + str(winner)


func setPlayerCount(count):
	playerCount = count
	
func setWinner(playernumber):
	winner = playernumber
	
func _on_btnExit_pressed():
	get_node("/root").add_child(startPage)
	get_node("/root").remove_child(self)


