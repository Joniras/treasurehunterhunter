extends Node2D

# only kind of works with odd numbers
const LABYRINTH_HEIGHT = 25
# only kind of works with odd numbers
const LABYRINTH_WIDTH = 25

# Temp fix for placing walls
const WALL_TILE = Vector2(0, 0)
const PASSAGE_TILE = Vector2(1,0)

const WALL = 0
const PASSAGE = 1
const ITEM = 2

var pendingCells: Array

# labyrinth (labyrinth) is a two dimensional array containing infos on which tile is 
# placed where.
var labyrinth = []

var types = ["stun","speed","slow","light","wall","path"]
	
var tile_size = 4

var min_item = 6
var max_item = 20

onready var player1 = $Player1
onready var player2 = $Player2
onready var player3 = $Player3
onready var player4 = $Player4
onready var playerHunter = $TreasureHunter
onready var item = preload("res://items/Item.tscn")

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
	remove_all_items()
	if (!createNewLabyrinth):
		redrawAllItems()
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


func remove_all_items():
	var children = self.get_children()
	for N in children:
		if("Item_" in N.name):
			# print("removed Item "+N.name)
			N.queue_free()
		if("Arrow" in N.name):
			# print("removed Item "+N.name)
			N.queue_free()

func redrawAllItems():
	var countItems = 0
	for column in range(LABYRINTH_WIDTH):
		for row in range(LABYRINTH_HEIGHT):
			if(labyrinth[column][row]==ITEM):
				add_item_mirrored(column, row, types[randi()%types.size()], countItems)
				countItems += 1
			
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
	sprinkleItems()
	add_item_mirrored(1,1,"light", max_item+1)
	add_item_mirrored(1,2,"light",  max_item+2)

func sprinkleItems():
	var countItems = min_item+randi()%(max_item-min_item);
	while countItems > 0:
		countItems -= 1
		var spotFound = false
		while !spotFound:
			var row = randi()%LABYRINTH_HEIGHT-1
			var column = randi()%LABYRINTH_WIDTH-1
			var walls = 0
			if(labyrinth[column][row]== PASSAGE):
				if(labyrinth[column+1][row] == WALL):
					walls += 1
				if(labyrinth[column-1][row] == WALL):
					walls += 1
				if(labyrinth[column][row+1] == WALL):
					walls += 1
				if(labyrinth[column][row-1] == WALL):
					walls += 1
				if(walls==3):
					spotFound = true
					add_item_mirrored(column,row,types[randi()%types.size()],countItems)
					break
	
func add_item_mirrored(x,y,type,id):
	print("Added "+str(id)+" with type "+type)
	add_item(x,y,type,str(id)+str(1))
	add_item(2*LABYRINTH_WIDTH-x-1,y,type,str(id)+str(3))
	add_item(x,2*LABYRINTH_HEIGHT-y-1,type,str(id)+str(4))
	add_item(2*LABYRINTH_WIDTH-x-1,2*LABYRINTH_HEIGHT-y-1,type,str(id)+str(2))
	labyrinth[x][y] = ITEM

	
func add_item(x,y, type, id):
	var new_item = item.instance()
	new_item.type = type
	new_item.name = "Item_"+str(id)
	new_item.id = id
	new_item.position = Vector2(x*tile_size+2,y*tile_size+2)
	self.add_child(new_item)
	
	
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
	$"Node2D/TileMap".set_cell(position.x, position.y, 0, false, false, false, tile)

func destroy_tiles(position_vector):
	
	# manip position
	var x = (position_vector.x - 2) / 4
	var y = (position_vector.y - 2) / 4
	$"Node2D/TileMap".set_cell(x + 1, y, 0, false, false, false, PASSAGE_TILE)
	$"Node2D/TileMap".set_cell(x, y + 1, 0, false, false, false, PASSAGE_TILE)
	$"Node2D/TileMap".set_cell(x - 1, y, 0, false, false, false, PASSAGE_TILE)
	$"Node2D/TileMap".set_cell(x, y - 1, 0, false, false, false, PASSAGE_TILE)
	
func addArrow(pos, playerId, direction):
	var arrow = load("res://ShortestPath/Arrow.tscn").instance()
	arrow.name = "Arrow"
	# pfeil schaut per default nach recht (direction= (1, 0))
	if (direction.x == 1 && direction.y == 0):
		pass
	if (direction.x == -1 && direction.y == 0):
		arrow.rotate(-PI)
	if (direction.x == 0 && direction.y == 1):
		arrow.rotate(PI / 2)
	if (direction.x == 0 && direction.y == -1):
		arrow.rotate(3 * PI / 2)
	
	arrow.position = Vector2(pos.x*tile_size+2, pos.y*tile_size+2)
	self.add_child(arrow)

func _on_Map_roundOver(recreateMap):
	init(recreateMap)
