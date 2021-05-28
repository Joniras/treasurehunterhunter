extends Node2D


const GRID_HEIGHT = 100
const GRID_WIDTH = 100

# Temp fix for placing walls
const WALL_TILE = Vector2(0, 0)
const GROUND_TILE = Vector2(3,3)

const WALL = 0
const PASSAGE = 1

# lab (labyrinth) is a two dimensional array containing infos on which tile is 
# placed where.
var lab = []


func _ready():
	lab.resize(GRID_HEIGHT)
	
	# for creating the labyrinth, we use Randomized Prim's Algorithm:
	

	# 1. A Grid consists of a 2 dimensional array of cells.
	# 2. A Cell has 2 states: Blocked or Passage.
	# 3. Start with a Grid full of Cells in state Blocked.
	# 4. Pick a random Cell, set it to state Passage and Compute its frontier cells. 
	#		A frontier cell of a Cell is a cell with distance 2 in state Blocked and within the grid.
	# 5. While the list of frontier cells is not empty:
	#	5.1 Pick a random frontier cell from the list of frontier cells.
	#	5.2 Let neighbors(frontierCell) = All cells in distance 2 in state Passage. 
	#	5.3 Pick a random neighbor and connect the frontier cell with the 
	#		neighbor by setting the cell in-between to state Passage. 
	#	5.4 Compute the frontier cells of the chosen frontier cell and add them to the frontier list. 
	#	5.5 Remove the chosen frontier cell from the list of frontier cells.

	# init the labyrinth:
	for i in GRID_HEIGHT:
		lab[i] = []
		lab[i].resize(GRID_WIDTH)
		for j in GRID_WIDTH:
			# init the Labyrinth:
			lab[i][j] = WALL

	var randomCell = Vector2(randi() % GRID_HEIGHT, randi() % GRID_WIDTH)
	lab[randomCell.x][randomCell.y] = PASSAGE
	var frontierCells = getNeighbouringCellsInState(randomCell)
	
	while frontierCells.size() > 1:
		var nextCell: Vector2 = frontierCells[randi() % frontierCells.size()]
		var neighbouringFrontierCells = getNeighbouringCellsInState(nextCell, PASSAGE)
		
		var randomNeighbour: Vector2 = neighbouringFrontierCells[randi() % neighbouringFrontierCells.size()]
		var inBetweenCell = randomNeighbour - nextCell
		

	for i in GRID_HEIGHT:
		for j in GRID_WIDTH:
			$TileMap.set_cell(i, j, 0, false, false, false, lab[i][j])

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
	if down < GRID_HEIGHT - 1 && lab[cell.x][down] == state:
		frontierCells.append(Vector2(cell.x, down))
	# left
	if left > 1 && lab[left][cell.y] == state:
		frontierCells.append(Vector2(left, cell.y))
	# right
	if right < GRID_WIDTH - 1 && lab[right][cell.y] == state:
		frontierCells.append(Vector2(right, cell.y))
	
	
	return frontierCells
