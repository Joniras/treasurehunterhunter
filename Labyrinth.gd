extends Node2D

# only kind of works with odd numbers
const LABYRINTH_HEIGHT = 21
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

func _ready():
	randomize()
	initLabyrinth()
	
	# Start from 1, 1
	generateAndDrawLabyrinth(Vector2(1, 1))
	
	# now we have a quadrant ready for player 1 in the labyrinth list
	# mirror it, then we get the maze for player 2
	
	for i in LABYRINTH_WIDTH:
		for j in LABYRINTH_HEIGHT:
			# upper right
			drawTile(Vector2(LABYRINTH_WIDTH + i, j), WALL_TILE if labyrinth[LABYRINTH_WIDTH - 1 - i][j] == WALL else PASSAGE_TILE)
			
			# lower left
			drawTile(Vector2(i, LABYRINTH_HEIGHT + j), WALL_TILE if labyrinth[i][LABYRINTH_HEIGHT - 1 - j] == WALL else PASSAGE_TILE)
			
			# lower right
			drawTile(Vector2(LABYRINTH_WIDTH + i, LABYRINTH_HEIGHT + j), WALL_TILE if labyrinth[LABYRINTH_WIDTH - 1 - i][LABYRINTH_HEIGHT - 1 - j] == WALL else PASSAGE_TILE)
			
			
	

# using Randomized Prim's Algorithm to generate a maze
func generateAndDrawLabyrinth(startingCell: Vector2):
	labyrinth[startingCell.x][startingCell.y] = PASSAGE
	drawTile(startingCell, PASSAGE_TILE)
	
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
			
			drawTile(randomWall, PASSAGE_TILE)
			drawTile(possibleCell, PASSAGE_TILE)
			
			pendingCells.append_array(getNeighbouringCellsInState(possibleCell, WALL))
			
		pendingCells.remove(randomWallIndex)
		
	# add starting Room and end room in the labyrinth
	drawStartingRoom()
	drawEndRoom()

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
	
func drawStartingRoom():
	var startingPositions = [Vector2(0, 0), Vector2(0, 1), Vector2(1, 0)]
	for pos in startingPositions:
		drawTile(pos, PASSAGE_TILE)
		labyrinth[pos.x][pos.y] = PASSAGE
	
func drawEndRoom():
	var endingPositions = [Vector2(LABYRINTH_WIDTH - 2, LABYRINTH_HEIGHT - 1),
		Vector2(LABYRINTH_WIDTH - 1, LABYRINTH_HEIGHT - 1),
		Vector2(LABYRINTH_WIDTH - 1, LABYRINTH_HEIGHT - 2)]
		
	for pos in endingPositions:
		drawTile(pos, PASSAGE_TILE)
		labyrinth[pos.x][pos.y] = PASSAGE
	
# position: position in the tilemap
# tile: position in the tileset
func drawTile(position: Vector2, tile: Vector2):
	$TileMap.set_cell(position.x, position.y, 0, false, false, false, tile)

