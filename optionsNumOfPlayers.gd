extends OptionButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	add_item("2 players", 2);
	add_item("3 players", 3);
	add_item("4 players", 4);


	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
