extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_enter ", self, "on_win")
	
	
func on_win(body):
	print(body)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
