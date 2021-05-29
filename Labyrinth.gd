extends TileMap

# only kind of works with odd numbers
const LABYRINTH_HEIGHT = 25
# only kind of works with odd numbers
const LABYRINTH_WIDTH = 25

# Temp fix for placing walls
const WALL_TILE = Vector2(0, 0)
const PASSAGE_TILE = Vector2(3,3)

const WALL = 0
const PASSAGE = 1

var pendingCells: Array

# labyrinth (labyrinth) is a two dimensional array containing infos on which tile is 
# placed where.
var labyrinth = []

var tile_size = 4

onready var player1 = $Player1
onready var player2 = $Player2
onready var player3 = $Player3
onready var player4 = $Player4
onready var playerHunter = $TreasureHunter

func set_player_positions():
	player1.position = Vector2(0,0)
	player1.adjustPositionToGrid()
	player2.position = Vector2(LABYRINTH_WIDTH*tile_size*2-tile_size,LABYRINTH_HEIGHT*tile_size*2-tile_size)
	player2.adjustPositionToGrid()
	player3.position = Vector2(LABYRINTH_WIDTH*tile_size*2-tile_size, 0)
	player3.adjustPositionToGrid()
	player4.position = Vector2(0,LABYRINTH_HEIGHT*tile_size*2-tile_size)
	player4.adjustPositionToGrid()
	playerHunter.position = Vector2(LABYRINTH_HEIGHT*tile_size,LABYRINTH_HEIGHT*tile_size)
	
	
func _ready():
	init(true)
	

func init(createNewLabyrinth):
	set_player_positions()
	
	if (!createNewLabyrinth):
		return

	initLabyrinth()
	# Start from 1, 1
	generateLabyrinth(Vector2(1, 1))
	
	# now we have a quadrant ready for player 1 in the labyrinth list
	# mirror it, then we get the maze for player 2
	
	for i in LABYRINTH_WIDTH:
		for j in LABYRINTH_HEIGHT:
			# upper left
			drawTile(Vector2(i, j), WALL_TILE if labyrinth[i][j] == WALL else PASSAGE_TILE)
			
			# upper right
			drawTile(Vector2(LABYRINTH_WIDTH + i, j), WALL_TILE if labyrinth[LABYRINTH_WIDTH - 1 - i][j] == WALL else PASSAGE_TILE)
			
			# lower left
			drawTile(Vector2(i, LABYRINTH_HEIGHT + j), WALL_TILE if labyrinth[i][LABYRINTH_HEIGHT - 1 - j] == WALL else PASSAGE_TILE)
			
			# lower right
			drawTile(Vector2(LABYRINTH_WIDTH + i, LABYRINTH_HEIGHT + j), WALL_TILE if labyrinth[LABYRINTH_WIDTH - 1 - i][LABYRINTH_HEIGHT - 1 - j] == WALL else PASSAGE_TILE)

	for i in range(-1,LABYRINTH_WIDTH*2+1):
		drawTile(Vector2(i,LABYRINTH_HEIGHT*2), WALL_TILE)
		drawTile(Vector2(i, -1), WALL_TILE)
	for i in range(-1,LABYRINTH_HEIGHT*2+1):
		drawTile(Vector2(LABYRINTH_WIDTH*2,i), WALL_TILE)
		drawTile(Vector2(-1,i), WALL_TILE)

# using Randomized Prim's Algorithm to generate a labyrinth inside the
# labyrinth matrix
func generateLabyrinth(startingCell: Vector2):
	labyrinth[startingCell.x][startingCell.y] = PASSAGE
	
	pendingCells = getNeighbouringCellsInState(startingCell, WALL, 1)

	while !pendingCells.empty():
		var randomWallIndex = randi() % pendingCells.size()
		var randomWall = pendingCells[randomWallIndex]
		
		var neighboursOfRandomWall = getNeighbouringCellsInState(randomWall, PASSAGE)
		
		if neighboursOfRandomWall.size() != 1:
			pendingCells.remove(randomWallIndex)
			continue
		
		var dir = randomWall - neighboursOfRandomWall[0]
		
		var possibleCell = Vector2(dir.x + randomWall.x, dir.y + randomWall.y)
		
		if checkBounds(possibleCell) && labyrinth[possibleCell.x][possibleCell.y] == WALL:
			labyrinth[randomWall.x][randomWall.y] = PASSAGE
			labyrinth[possibleCell.x][possibleCell.y] = PASSAGE
			
			pendingCells.append_array(getNeighbouringCellsInState(possibleCell, WALL))
			
		pendingCells.remove(randomWallIndex)
		
	# add starting Room and end room in the labyrinth
	var startAndEndPositions = [Vector2(0, 0), Vector2(0, 1), Vector2(1, 0),
		Vector2(LABYRINTH_WIDTH - 2, LABYRINTH_HEIGHT - 1),
		Vector2(LABYRINTH_WIDTH - 1, LABYRINTH_HEIGHT - 1),
		Vector2(LABYRINTH_WIDTH - 1, LABYRINTH_HEIGHT - 2)]
	
	for pos in startAndEndPositions:
		labyrinth[pos.x][pos.y] = PASSAGE
	

# inits the quadrant of the whole labyrinth with wall tiles
func initLabyrinth():
	labyrinth.resize(LABYRINTH_WIDTH)
	# init the labyrinth:
	for i in LABYRINTH_WIDTH:
		labyrinth[i] = []
		labyrinth[i].resize(LABYRINTH_HEIGHT)
		for j in LABYRINTH_HEIGHT:
			# init the Labyrinth:
			labyrinth[i][j] = WALL
			drawTile(Vector2(i, j), WALL_TILE)


# Returns list of Vectors, which represent coordinates in labyrinth.
# the returned list of vectors is a list of neighbouring cells.
func getNeighbouringCellsInState(cell: Vector2, state: int = WALL, distance: int = 1):
	var neighbourCells = []
	
	var up = cell.y - distance
	var down = cell.y + distance
	var left = cell.x - distance
	var right = cell.x + distance
	
	# up
	if up >= 0 && labyrinth[cell.x][up] == state:
		neighbourCells.append(Vector2(cell.x, up))
	# down
	if down < LABYRINTH_HEIGHT && labyrinth[cell.x][down] == state:
		neighbourCells.append(Vector2(cell.x, down))
	# left
	if left >= 0 && labyrinth[left][cell.y] == state:
		neighbourCells.append(Vector2(left, cell.y))
	# right
	if right < LABYRINTH_WIDTH && labyrinth[right][cell.y] == state:
		neighbourCells.append(Vector2(right, cell.y))
	
	return neighbourCells

func checkBounds(cell: Vector2):
	return cell.x > 0 && cell.x < LABYRINTH_WIDTH &&  cell.y > 0 && cell.y < LABYRINTH_HEIGHT
	
# position: position in the tilemap
# tile: position in the tileset
func drawTile(position: Vector2, tile: Vector2):
	set_cell(position.x, position.y, 0, false, false, false, tile)



func _on_Map_roundOver(recreateMap):
	init(recreateMap)