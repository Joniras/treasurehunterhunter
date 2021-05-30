extends Node

# Returns a Vector2 to get the direction of the shortest path to the center of
# the labyrinth.
# The Returned Value specifically is either (0, 0), (0, 1), (0, -1), (1, 0), (-1, 0)
# the calculation is done for one quadrant. for each player we need to adjust
# the direction by mirroring once/twice along some axis.
func getDirectionOfShortestPath(labyrinth, start: Vector2, end: Vector2):
	var shortestPath = bfs(labyrinth, start, end)
	
	if shortestPath.size() < 2:
		return Vector2(0, 0)
	
	var dir = shortestPath[1] - shortestPath[0]
	
	return Vector2(dir.x, dir.y)
	

func bfs(grid, start, goal):
	var queue = [[start]]
	var seen := [start]
	while queue:
		var path = queue.pop_back()
		var next = path[-1]
		var x = next.x
		var y = next.y
		if next == goal:
			print(path)
			return path
		for v in [Vector2(x+1,y), Vector2(x-1,y), Vector2(x,y+1), Vector2(x,y-1)]:
			# Wall == 0, Passage == 1 inside grid
			if checkBounds(v, grid.size(), grid[0].size()) and grid[v.x][v.y] != 0 and !seen.has(v):
				queue.append(path + [v])
				seen.append(v)


func checkBounds(cell: Vector2, width, height):
	return cell.x > 0 && cell.x < width &&  cell.y > 0 && cell.y < height
