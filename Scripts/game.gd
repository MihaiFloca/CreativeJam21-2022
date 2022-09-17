extends Node

enum OBJECTS { EMPTY, GOAL, TELEPORTER, BOX, PLANT1, PLANT2, WALL }
var present_grid = []
var future_grid = []
var map = null

# Called when the node enters the scene tree for the first time.
func _ready():
	init_objects()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func init_array(size):
	var grid = [[]]
	
	for y in size.y:
		grid.resize(size.y)
		for x in size.x:
			grid[y] = []
			grid[y].resize(size.x)
		for x in size.x:
			grid[y][x] = OBJECTS.EMPTY
		
	return grid
	
func init_objects():
	for timeline in get_children():
		if timeline.name == "Sprite2D":
			continue

		if timeline.get_node('Terrain') != null and map == null:
			map = timeline.get_node('Terrain')

		var grid_size = map.get_used_rect().size
		var grid = init_array(grid_size)
		
		for type in timeline.get_children():
			if type.get_child_count() == 0:
				continue
			if type.get_child(0).name != "TileMap":
				continue

			for cell in type.get_child(0).get_used_cells(0):
				grid[cell.y][cell.x] = get_object_type(type.name)
			
		if timeline.name == "Present":
			present_grid = grid
		elif timeline.name == "Future":
			future_grid = grid



func get_object_type(name):
	if name == "Plant1":
		return OBJECTS.PLANT1
