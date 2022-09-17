extends Node

enum OBJECTS { PLANT1, WALL, TELEPORTER, BOX, PLANT2, GOAL, PLANT1_GROWN, EMPTY }
var action_cooldown_limit = 1
var action_cooldown = action_cooldown_limit-action_cooldown_limit
var player_present = null
var player_future = null
var map = null
var objects_map_present = null
var objects_map_future = null
var CELL_SIZE = 16
var timeline = "Present"
var obj_in_hand = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	init_objects()
	#interact_cell("Present", Vector2(6,3), OBJECTS.PLANT1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("move_left") and action_cooldown >= action_cooldown_limit:
		move(-CELL_SIZE, 0)
		action_cooldown = 0
	if Input.is_action_pressed("move_right") and action_cooldown >= action_cooldown_limit:
		move(CELL_SIZE, 0)
		action_cooldown = 0
	if Input.is_action_pressed("move_down") and action_cooldown >= action_cooldown_limit:
		move(0, CELL_SIZE)
		action_cooldown = 0
	if Input.is_action_pressed("move_up") and action_cooldown >= action_cooldown_limit:
		move(0, -CELL_SIZE)
		action_cooldown = 0
	if Input.is_action_pressed("pick_up") and action_cooldown >= action_cooldown_limit:
		action_cooldown = 0
		if obj_in_hand == -1:
			grab_object()
		else:
			drop_object()
	if Input.is_action_pressed("interact") and action_cooldown >= action_cooldown_limit:
		interact_cell(player_present)
		action_cooldown = 0
	if action_cooldown <= action_cooldown_limit:
		action_cooldown += 0.1

func move(x, y):
	var time_pos = null
	if timeline == "Present":
		time_pos = player_present
	elif timeline == "Future":
		time_pos = player_future
	var pos = Vector2(time_pos.position.x + x, time_pos.position.y + y)
	if check_cell(map.world_to_map(pos)):
		time_pos.set_position(pos)
# player_pos: the cell the player is trying to go into
# return: if the player can move to the next cell
func check_cell(player_pos):
	var object_id = find_object_id(player_pos)
	if object_id == OBJECTS.EMPTY:
		return true
	if object_id == OBJECTS.WALL:
		return false
	if object_id == OBJECTS.PLANT1_GROWN:
		return true
	
	return true

func grab_object():
	# already holding something
	if obj_in_hand > -1:
		return
	
	var time_pos = null
	var time_map = null
	if timeline == "Present":
		time_pos = player_present
		time_map = objects_map_present
	elif timeline == "Future":
		time_pos = player_future
		time_map = objects_map_future
	
	var grabbed_obj = find_object_id(time_map.world_to_map(time_pos.position))
	print("Grabbed id: " + str(grabbed_obj))
	
	if grabbed_obj == OBJECTS.PLANT1: # todo
		if grab_plant1():
			return

	var pos = time_map.world_to_map(time_pos.position)
	objects_map_present.set_cell(pos.x, pos.y, -1)
	#objects_map_future.set_cell(pos.x, pos.y, -1)

func drop_object():
	if obj_in_hand == -1 or timeline == "Future":
		return
	obj_in_hand = -1
	#if timeline == "Present":
	drop_plant1(objects_map_present.world_to_map(player_present.position))
	
# player_pos: current player pos when pressed e (interact button)
func interact_cell(player_pos):#, object_in_hand):		
	if timeline == "Present":
		timeline = "Future"
		player_future.position = player_present.position
		grow_plants()
		print(obj_in_hand)
		
		get_child(1).visible = true
		get_child(0).visible = false
	elif timeline == "Future":
		timeline = "Present"
		player_present.position = player_future.position
		
		get_child(0).visible = true
		get_child(1).visible = false
	
func find_object_id(player_pos):
	var map_temp = null
	if timeline == "Present":
		map_temp = objects_map_present
		
	elif timeline == "Future":
		map_temp = objects_map_future
		
	var index = map_temp.get_used_cells().find(player_pos, 0)
	#print(index)
	if index < 0: 
		return OBJECTS.EMPTY
	var obj = map_temp.get_used_cells()[index]
	var id = map_temp.get_cellv(obj)
	return id

func grab_plant1():
	if timeline == "Future":
		return

	obj_in_hand = 1
	#var p_pos = map.
	
func drop_plant1(player_pos):
	print("plant dropped")
	objects_map_present.set_cell(player_pos.x, player_pos.y, 0)
	
func grow_plants():
	for obj in objects_map_future.get_used_cells():
		var id = objects_map_future.get_cellv(obj)
		if id == 0:
			objects_map_future.set_cell(obj.x, obj.y, -1)
			
	for obj in objects_map_present.get_used_cells():
		var id = objects_map_present.get_cellv(obj)
		if id == 0:
			objects_map_future.set_cell(obj.x, obj.y, 0)
			objects_map_future.set_cell(obj.x, obj.y - 1, 0)
			objects_map_future.set_cell(obj.x, obj.y - 2, 0)
	#var growth_size = 3
	#var x = player_pos.x
	#var y = player_pos.y
	#for i in growth_size:
	#	if y - i >= 0:
	#		objects_map_future.set_cell(x, y-i, 0)

func init_objects():
	for tt in get_children():
		if tt.name == "Sprite2D":
			continue
		
		var objects_map = tt.get_node("Objects")
		
		var player = tt.get_node("Player")
		
		if tt.get_node('Terrain') != null and map == null:
			map = tt.get_node('Terrain')

		if tt.name == "Present":
			objects_map_present = objects_map
			player_present = player
		elif tt.name == "Future":
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
