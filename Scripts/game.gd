extends Node

enum OBJECTS { EMPTY, GOAL, TELEPORTER, BOX, PLANT1, PLANT2, WALL, PLANT1_GROWN }
var action_cooldown_limit = 2
var action_cooldown = action_cooldown_limit-action_cooldown_limit
var player_present = null
var player_future = null
var map = null
var objects_map_present = null
var objects_map_future = null
var CELL_SIZE = 16
var timeline = "Present"

# Called when the node enters the scene tree for the first time.
func _ready():
	init_objects()
	interact_cell("Present", Vector2(6,3), OBJECTS.PLANT1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("move_left") and action_cooldown >= action_cooldown_limit:
		print("move_left")
		move(-CELL_SIZE, 0)
		action_cooldown = 0
	if Input.is_action_pressed("move_right") and action_cooldown >= action_cooldown_limit:
		print("move_right")
		move(CELL_SIZE, 0)
		action_cooldown = 0
	if Input.is_action_pressed("move_down") and action_cooldown >= action_cooldown_limit:
		print("move_down")
		move(0, CELL_SIZE)
		action_cooldown = 0
	if Input.is_action_pressed("move_up") and action_cooldown >= action_cooldown_limit:
		print("move_up")
		move(0, -CELL_SIZE)
		action_cooldown = 0
	if Input.is_action_pressed("pick_up") and action_cooldown >= action_cooldown_limit:
		print("pick_up")
		action_cooldown = 0
	if Input.is_action_pressed("interact") and action_cooldown >= action_cooldown_limit:
		print("interact")
		action_cooldown = 0
	if action_cooldown <= action_cooldown_limit:
		action_cooldown += 0.1

func move(x, y):
	var pos = Vector2(player_present.position.x + x, player_present.position.y + y)
	if check_cell(map.world_to_map(pos)):
		player_present.set_position(pos)
# player_pos: the cell the player is trying to go into
# return: if the player can move to the next cell
func check_cell(player_pos):
	var object = null
	object = find_object(timeline, player_pos)
	print(object)
	if object == OBJECTS.EMPTY:
		return true
	if object == OBJECTS.WALL:
		return false
	if object == OBJECTS.PLANT1_GROWN:
		return true

# player_pos: current player pos when pressed e (interact button)
func interact_cell(timeline, player_pos, object_in_hand):
	var object = find_object(timeline, player_pos)

	if object_in_hand == OBJECTS.PLANT1:
		drop_plant1(player_pos)
	
func find_object(timeline, player_pos):
	var map_temp = null
	if timeline == "Present":
		map_temp = objects_map_present
		
	elif timeline == "Future":
		map_temp = objects_map_future
		
	var index = map_temp.get_used_cells().find(player_pos, 0)
	print(index)
	if index < 0: 
		return OBJECTS.EMPTY
	var obj = map_temp.get_used_cells()[index]
	var id = map_temp.get_cellv(obj)
	return OBJECTS.WALL # convert to enum later
		

func drop_plant1(player_pos):
	var growth_size = 3
	var x = player_pos.x
	var y = player_pos.y
	for i in growth_size:
		if y - i >= 0:
			pass#objects_map_future.set_cell(x, y-i, 0)

func init_objects():
	for timeline in get_children():
		if timeline.name == "Sprite2D":
			continue
		
		var objects_map = timeline.get_node("Objects")
		
		var player = timeline.get_node("Player")
		
		if timeline.get_node('Terrain') != null and map == null:
			map = timeline.get_node('Terrain')

		if timeline.name == "Present":
			objects_map_present = objects_map
			player_present = player
		elif timeline.name == "Future":
			objects_map_future = objects_map
			player_future = player

func get_object_type(id):
	if id == 1:
		return OBJECTS.PLANT1


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
