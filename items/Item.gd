extends KinematicBody2D

export var type = "stun"
export var id = 1

onready var sprite = $Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = load("res://items/"+type+"_item.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
