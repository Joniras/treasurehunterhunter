extends Node2D


const GRID_HEIGHT = 25
const GRID_WIDTH = 25

# Temp fix for placing walls
const WALL_TILE = Vector2(0, 0)
const PASSAGE_TILE = Vector2(3,3)

const WALL = 0
const PASSAGE = 1

var pendingCells: Array

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
			# init the Labyrinth:
			lab[i][j] = WALL
			$TileMap.set_cell(i, j, 0, false, false, false, WALL_TILE)
	
	
	var randomCell = Vector2(randi() % GRID_HEIGHT, randi() % GRID_WIDTH)
	lab[randomCell.x][randomCell.y] = PASSAGE
	
	$TileMap.set_cell(randomCell.x, randomCell.y, 0, false, false, false, PASSAGE_TILE)
	
	pendingCells = getNeighbouringCellsInState(randomCell, WALL, 1)

func _process(delta):
	OS.delay_msec(50)
	if !pendingCells.empty():
		var randomWallIndex = randi() % pendingCells.size()
		var randomWall = pendingCells[randomWallIndex]
		
		var neighboursOfRandomWall = getNeighbouringCellsInState(randomWall, PASSAGE, 1)
		
		if neighboursOfRandomWall.size() != 1:
			pendingCells.remove(randomWallIndex)
			return
		
		var dir = randomWall - neighboursOfRandomWall[0]
		
		var possibleCell = Vector2(dir.x + randomWall.x, dir.y + randomWall.y)
		
		if checkBounds(possibleCell) && lab[possibleCell.x][possibleCell.y] == WALL:
			lab[randomWall.x][randomWall.y] = PASSAGE
			lab[possibleCell.x][possibleCell.y] = PASSAGE
			
			$TileMap.set_cell(randomWall.x, randomWall.y, 0, false, false, false, PASSAGE_TILE)
			$TileMap.set_cell(possibleCell.x, possibleCell.y, 0, false, false, false, PASSAGE_TILE)
			
			# pendingCells.append_array(getNeighbouringCellsInState(randomWall, WALL, 1))
			pendingCells.append_array(getNeighbouringCellsInState(possibleCell, WALL, 1))
			
		pendingCells.remove(randomWallIndex)
		

# Returns list of Vectors, which represent coordinates in lab.
# the returned list of vectors is a list of frontier cells.
# A frontier cell of a Cell is a cell with distance 2 in state Blocked and within the grid.
func getNeighbouringCellsInState(cell: Vector2, state: int = WALL, distance: int = 2):
	var frontierCells = []
	
	var up = cell.y - distance
	var down = cell.y + distance
	var left = cell.x - distance
	var right = cell.x + distance
	
	# up
	if up > 1 && lab[cell.x][up] == state:
		frontierCells.append(Vector2(cell.x, up))
	# down
	if down < GRID_HEIGHT && lab[cell.x][down] == state:
		frontierCells.append(Vector2(cell.x, down))
	# left
	if left > 1 && lab[left][cell.y] == state:
		frontierCells.append(Vector2(left, cell.y))
	# right
	if right < GRID_WIDTH && lab[right][cell.y] == state:
		frontierCells.append(Vector2(right, cell.y))
	
	
	return frontierCells

func checkBounds(cell: Vector2):
	return cell.x > 0 && cell.x < GRID_WIDTH &&  cell.y > 0 && cell.y < GRID_HEIGHT
