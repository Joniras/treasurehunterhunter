extends Node2D


const GRID_HEIGHT = 100
const GRID_WIDTH = 100

# Temp fix for placing walls
const WALL = Vector2(0, 0)
const GROUND = Vector2(3,3)

# lab (labyrinth) is a two dimensional array containing infos on which tile is 
# placed where.
var lab = []

func _ready():
	lab.resize(GRID_HEIGHT)
	
	# init the labyrinth:
	for i in GRID_HEIGHT:
		lab[i] = []
		lab[i].resize(GRID_WIDTH)
		for j in GRID_WIDTH:
			# define the labyrinth
			lab[i][j] = WALL if randi() % 2 == 1 else GROUND

	for i in GRID_HEIGHT:
		for j in GRID_WIDTH:
			$TileMap.set_cell(i, j, 0, false, false, false, lab[i][j])
