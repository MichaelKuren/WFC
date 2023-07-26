class_name WFCGenerator

extends Node3D

var tiles_data: Dictionary = {
	0 : {
		"mesh_name" : "grass.res",
		"rotation" : 0,
		"weight" : 1,
		"sockets" : ["1s", "1s", "1s", "1s"],
		"neighbors" : [[], [], [], []]
	},
	
	1 : {
		"mesh_name" : "grass_corner.res",
		"rotation" : 0,
		"weight" : 1,
		"sockets" : ["-1s", "2f", "2", "-1s"],
		"neighbors" : [[], [], [], []]
	},
	
	2 : {
		"mesh_name" : "grass_corner_in.res",
		"rotation" : 0,
		"weight" : 1,
		"sockets" : ["2f", "1s", "1s", "2"],
		"neighbors" : [[], [], [], []]
	},
	
	3 : {
		"mesh_name" : "grass_forest.res",
		"rotation" : 0,
		"weight" : 1,
		"sockets" : ["1s", "1s", "1s", "1s"],
		"neighbors" : [[], [], [], []]
	},
	
	4 : {
		"mesh_name" : "grass_house.res",
		"rotation" : 0,
		"weight" : 1,
		"sockets" : ["1s", "1s", "1s", "1s"],
		"neighbors" : [[], [], [], []]
	},
	
	5 : {
		"mesh_name" : "grass_slope.res",
		"rotation" : 0,
		"weight" : 1,
		"sockets" : ["-1s", "2f", "1s", "2"],
		"neighbors" : [[], [], [], []]
	},
	
	6 : {
		"mesh_name" : "-1",
		"rotation" : 0,
		"weight" : 1,
		"sockets" : ["-1s", "-1s", "-1s", "-1s"],
		"neighbors" : [[], [], [], []]
	},
}

var tiles_path: String = "res://assets/tiles/"

@export var size: Vector2i

var grid_data: Array
var cords_stack: Array

func handle_rotations() -> void:
	var keys = tiles_data.keys() 
	var last_indx: int = keys.size()

	for rot in range(1, 4):
		for tile_name in range(0, keys.size() - 1): # last key - blank tile
			var sockets: Array = tiles_data[tile_name]["sockets"].duplicate()
			for i in rot:
				var last = sockets[-1]
				sockets.pop_back()
				sockets.push_front(last)

			tiles_data[last_indx] = {
				"mesh_name" : tiles_data[tile_name]["mesh_name"],
				"rotation" : rot,
				"weight" : tiles_data[tile_name]["weight"],
				"sockets" : sockets,
				"neighbors" : [[], [], [], []]
			}

			last_indx += 1

func handle_neighbors() -> void:
	var keys = tiles_data.keys()

	for tile_name in keys:
		var neighbors: Array = tiles_data[tile_name]["neighbors"]

		var tile_sockets = tiles_data[tile_name]["sockets"]
		for neighbor_name in keys:
			var neighbor_sockets = tiles_data[neighbor_name]["sockets"]
		
			if tile_sockets[0].ends_with("s") and neighbor_sockets[2].ends_with("s") and tile_sockets[0] == neighbor_sockets[2]:
				neighbors[0].append(neighbor_name)
			elif (tile_sockets[0].ends_with("f") and tile_sockets[0] == neighbor_sockets[2] + "f") or \
				 (neighbor_sockets[2].ends_with("f") and tile_sockets[0] + "f" == neighbor_sockets[2]):
				neighbors[0].append(neighbor_name)

			if tile_sockets[1].ends_with("s") and neighbor_sockets[3].ends_with("s") and tile_sockets[1] == neighbor_sockets[3]:
				neighbors[1].append(neighbor_name)
			elif (tile_sockets[1].ends_with("f") and tile_sockets[1] == neighbor_sockets[3] + "f") or \
				 (neighbor_sockets[3].ends_with("f") and tile_sockets[1] + "f" == neighbor_sockets[3]):
				neighbors[1].append(neighbor_name)
				
			if tile_sockets[2].ends_with("s") and neighbor_sockets[0].ends_with("s") and tile_sockets[2] == neighbor_sockets[0]:
				neighbors[2].append(neighbor_name)
			elif (tile_sockets[2].ends_with("f") and tile_sockets[2] == neighbor_sockets[0] + "f") or \
				 (neighbor_sockets[0].ends_with("f") and tile_sockets[2] + "f" == neighbor_sockets[0]):
				neighbors[2].append(neighbor_name)
				
			if tile_sockets[3].ends_with("s") and neighbor_sockets[1].ends_with("s") and tile_sockets[3] == neighbor_sockets[1]:
				neighbors[3].append(neighbor_name)
			elif (tile_sockets[3].ends_with("f") and tile_sockets[3] == neighbor_sockets[1] + "f") or \
				 (neighbor_sockets[1].ends_with("f") and tile_sockets[3] + "f" == neighbor_sockets[1]):
				neighbors[3].append(neighbor_name)

func get_min_entropy_cords() -> Vector2i:
	var min_entropy_cords: Vector2i
	var min_entropy = tiles_data.values().size() + 1
	for x in size.x:
		for y in size.y:
			if grid_data[x][y].values().size() < min_entropy and grid_data[x][y].values().size() > 1:
				min_entropy = grid_data[x][y].values().size()
				min_entropy_cords = Vector2i(x, y)

	return min_entropy_cords

func is_collapsed() -> bool:
	for x in size.x:
		for y in size.y:
			if grid_data[x][y].values().size() > 1:
				return false
	return true

func valid_dirs(cords: Vector2i) -> Array:
	var dirs: Array = []
	if (cords.x + 1) <= (size.x - 1) and (cords.x + 1) >= 0:
		dirs.append(Vector2i(1, 0))
	if (cords.y + 1) <= (size.y - 1) and (cords.y + 1) >= 0:
		dirs.append(Vector2i(0, 1))
	if (cords.x - 1) <= (size.x - 1) and (cords.x - 1) >= 0:
		dirs.append(Vector2i(-1, 0))
	if (cords.y - 1) <= (size.y - 1) and (cords.y - 1) >= 0:
		dirs.append(Vector2i(0, -1))
	return dirs

func get_possible_neighbors(current_cords: Vector2i, dir: Vector2i) -> Array:
	var possible_neighbors: Array = []
	if dir == Vector2i(1, 0):
		var tiles: Array = grid_data[current_cords.x][current_cords.y].values()
		for tile in tiles:
			var neighbors: Array = tile["neighbors"][0]
			for neighbor in neighbors:
				if neighbor not in possible_neighbors:
					possible_neighbors.append(neighbor)

	if dir == Vector2i(0, 1):
		var tiles: Array = grid_data[current_cords.x][current_cords.y].values()
		for tile in tiles:
			var neighbors: Array = tile["neighbors"][1]
			for neighbor in neighbors:
				if neighbor not in possible_neighbors:
					possible_neighbors.append(neighbor)

	if dir == Vector2i(-1, 0):
		var tiles: Array = grid_data[current_cords.x][current_cords.y].values()
		for tile in tiles:
			var neighbors: Array = tile["neighbors"][2]
			for neighbor in neighbors:
				if neighbor not in possible_neighbors:
					possible_neighbors.append(neighbor)

	if dir == Vector2i(0, -1):
		var tiles: Array = grid_data[current_cords.x][current_cords.y].values()
		for tile in tiles:
			var neighbors: Array = tile["neighbors"][3]
			for neighbor in neighbors:
				if neighbor not in possible_neighbors:
					possible_neighbors.append(neighbor)

	return possible_neighbors

func propagate(cords: Vector2i) -> void:
	cords_stack.append(cords)

	while cords_stack.size() > 0:
		var current_cords: Vector2i = cords_stack.pop_back()
		for dir in valid_dirs(current_cords):
			var neighbor_cords: Vector2i = current_cords + dir
			var neighbor_possible_tiles = grid_data[neighbor_cords.x][neighbor_cords.y].keys()

			if neighbor_possible_tiles.size() < 2:
				continue

			var possible_neighbors: Array = get_possible_neighbors(current_cords, dir)

			for neighbor_tile in neighbor_possible_tiles:
				if neighbor_tile not in possible_neighbors:
					grid_data[neighbor_cords.x][neighbor_cords.y].erase(neighbor_tile)
					if neighbor_cords not in cords_stack:
						cords_stack.append(neighbor_cords)

func collapse_at(cords: Vector2i) -> void:
	var collapsed_cell: Dictionary = {}
	var rand_tile_key: int = grid_data[cords.x][cords.y].keys().pick_random()
	collapsed_cell[rand_tile_key] = grid_data[cords.x][cords.y][rand_tile_key]
	grid_data[cords.x][cords.y] = collapsed_cell

func generate() -> void:
	for x in size.x:
		var row: Array = []
		for y in size.y:
			row.append(tiles_data.duplicate())
		grid_data.append(row)

	while not is_collapsed():
		var cell_pos = get_min_entropy_cords()
		collapse_at(cell_pos)
		propagate(cell_pos)

	for x in size.x:
		for y in size.y:
			var cell = grid_data[x][y].values()[0]
			if cell["mesh_name"] == "-1":
				continue

			var mesh = MeshInstance3D.new()
			mesh.mesh = load(tiles_path + cell["mesh_name"])
			mesh.position = Vector3(x, 0, -y)
			mesh.rotation.y = PI/2 * cell["rotation"]
			add_child(mesh)

	position = Vector3(-size.x / 2.0, 0, size.y / 2.0)

func _ready() -> void:
	handle_rotations()
	handle_neighbors()
	generate()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("regenerate"):
		grid_data.clear()
		for kid in get_children():
			remove_child(kid)

		generate()
