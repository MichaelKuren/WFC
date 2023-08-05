class_name WFCGenerator

extends Node3D

var tiles_data: Dictionary = {
	0 : {
		"mesh_name" : "grass.res",
		"rotation" : 0,
		"sockets" : ["1s", "1s", "1s", "1s"],
		"neighbors" : [[], [], [], []]
	},
	
	1 : {
		"mesh_name" : "grass_corner.res",
		"rotation" : 0,
		"sockets" : ["-1s", "2f", "2", "-1s"],
		"neighbors" : [[], [], [], []]
	},
	
	2 : {
		"mesh_name" : "grass_corner_in.res",
		"rotation" : 0,
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
		"sockets" : ["1s", "1s", "1s", "1s"],
		"neighbors" : [[], [], [], []]
	},
	
	5 : {
		"mesh_name" : "grass_slope.res",
		"rotation" : 0,
		"sockets" : ["-1s", "2f", "1s", "2"],
		"neighbors" : [[], [], [], []]
	},
	
	6 : {
		"mesh_name" : "-1",
		"rotation" : 0,
		"sockets" : ["-1s", "-1s", "-1s", "-1s"],
		"neighbors" : [[], [], [], []]
	},
}

var tiles_path: String = "res://assets/tiles/"

@export var size: Vector2i
@export var message_collapsed: Label
@export var message_start: Label

var grid_data: Array
var coords_stack: Array

func prepare_grid() -> void:
	grid_data.clear()
	for child in get_children():
		remove_child(child)

	for x in size.x:
		var row: Array = []
		for y in size.y:
			row.append(tiles_data.duplicate())
		grid_data.append(row)

func handle_rotations() -> void:
	var keys: Array = tiles_data.keys() 
	var last_indx: int = keys.size()

	for rot in range(1, 4):
		for tile_name in range(0, keys.size() - 1):
			var sockets: Array = tiles_data[tile_name]["sockets"].duplicate()
			for i in rot:
				var last: String = sockets[-1]
				sockets.pop_back()
				sockets.push_front(last)

			tiles_data[last_indx] = {
				"mesh_name" : tiles_data[tile_name]["mesh_name"],
				"rotation" : rot,
				"sockets" : sockets,
				"neighbors" : [[], [], [], []]
			}

			last_indx += 1

func handle_neighbors() -> void:
	var keys: Array = tiles_data.keys()

	for tile_name in keys:
		var neighbors: Array = tiles_data[tile_name]["neighbors"]
		var tile_sockets: Array = tiles_data[tile_name]["sockets"]

		for neighbor_name in keys:
			var neighbor_sockets: Array = tiles_data[neighbor_name]["sockets"]

			if tile_sockets[0].ends_with("s") and neighbor_sockets[2].ends_with("s") and \
					tile_sockets[0] == neighbor_sockets[2]:
				neighbors[0].append(neighbor_name)
			elif (tile_sockets[0].ends_with("f") and tile_sockets[0] == neighbor_sockets[2] + "f") or \
				 (neighbor_sockets[2].ends_with("f") and tile_sockets[0] + "f" == neighbor_sockets[2]):
				neighbors[0].append(neighbor_name)

			if tile_sockets[1].ends_with("s") and neighbor_sockets[3].ends_with("s") and \
					tile_sockets[1] == neighbor_sockets[3]:
				neighbors[1].append(neighbor_name)
			elif (tile_sockets[1].ends_with("f") and tile_sockets[1] == neighbor_sockets[3] + "f") or \
				 (neighbor_sockets[3].ends_with("f") and tile_sockets[1] + "f" == neighbor_sockets[3]):
				neighbors[1].append(neighbor_name)

			if tile_sockets[2].ends_with("s") and neighbor_sockets[0].ends_with("s") and \
					tile_sockets[2] == neighbor_sockets[0]:
				neighbors[2].append(neighbor_name)
			elif (tile_sockets[2].ends_with("f") and tile_sockets[2] == neighbor_sockets[0] + "f") or \
				 (neighbor_sockets[0].ends_with("f") and tile_sockets[2] + "f" == neighbor_sockets[0]):
				neighbors[2].append(neighbor_name)

			if tile_sockets[3].ends_with("s") and neighbor_sockets[1].ends_with("s") and \
					tile_sockets[3] == neighbor_sockets[1]:
				neighbors[3].append(neighbor_name)
			elif (tile_sockets[3].ends_with("f") and tile_sockets[3] == neighbor_sockets[1] + "f") or \
				 (neighbor_sockets[1].ends_with("f") and tile_sockets[3] + "f" == neighbor_sockets[1]):
				neighbors[3].append(neighbor_name)

func get_min_entropy_coords() -> Vector2i:
	var min_entropy_coords: Vector2i
	var min_entropy: int = tiles_data.values().size() + 1
	for x in size.x:
		for y in size.y:
			if grid_data[x][y].values().size() < min_entropy and grid_data[x][y].values().size() > 1:
				min_entropy = grid_data[x][y].values().size()
				min_entropy_coords = Vector2i(x, y)

	return min_entropy_coords

func is_collapsed() -> bool:
	for x in size.x:
		for y in size.y:
			if grid_data[x][y].values().size() > 1:
				return false
	return true

func valid_dirs(coords: Vector2i) -> Array:
	var dirs: Array = []
	if (coords.x + 1) <= (size.x - 1):
		dirs.append(Vector2i(1, 0))
	if (coords.y + 1) <= (size.y - 1):
		dirs.append(Vector2i(0, 1))
	if (coords.x - 1) >= 0:
		dirs.append(Vector2i(-1, 0))
	if (coords.y - 1) >= 0:
		dirs.append(Vector2i(0, -1))
	return dirs

func get_possible_neighbors(current_coords: Vector2i, dir: Vector2i) -> Array:
	var possible_neighbors: Array = []
	var tiles: Array = grid_data[current_coords.x][current_coords.y].values()

	if dir == Vector2i(1, 0):
		for tile in tiles:
			var neighbors: Array = tile["neighbors"][0]
			for neighbor in neighbors:
				if neighbor not in possible_neighbors:
					possible_neighbors.append(neighbor)

	if dir == Vector2i(0, 1):
		for tile in tiles:
			var neighbors: Array = tile["neighbors"][1]
			for neighbor in neighbors:
				if neighbor not in possible_neighbors:
					possible_neighbors.append(neighbor)

	if dir == Vector2i(-1, 0):
		for tile in tiles:
			var neighbors: Array = tile["neighbors"][2]
			for neighbor in neighbors:
				if neighbor not in possible_neighbors:
					possible_neighbors.append(neighbor)

	if dir == Vector2i(0, -1):
		for tile in tiles:
			var neighbors: Array = tile["neighbors"][3]
			for neighbor in neighbors:
				if neighbor not in possible_neighbors:
					possible_neighbors.append(neighbor)

	return possible_neighbors

func propagate(coords: Vector2i) -> void:
	coords_stack.append(coords)

	while coords_stack.size() > 0:
		var current_coords: Vector2i = coords_stack.pop_back()
		for dir in valid_dirs(current_coords):
			var neighbor_coords: Vector2i = current_coords + dir
			var neighbor_possible_tiles: Array = grid_data[neighbor_coords.x][neighbor_coords.y].keys()

			if neighbor_possible_tiles.size() < 2:
				continue

			var possible_neighbors: Array = get_possible_neighbors(current_coords, dir)

			for neighbor_tile in neighbor_possible_tiles:
				if neighbor_tile not in possible_neighbors:
					grid_data[neighbor_coords.x][neighbor_coords.y].erase(neighbor_tile)

					if neighbor_coords not in coords_stack:
						coords_stack.append(neighbor_coords)

					if grid_data[neighbor_coords.x][neighbor_coords.y].keys().size() == 1:
						draw_cell(neighbor_coords)

func collapse_at(coords: Vector2i) -> void:
	var collapsed_cell: Dictionary = {}
	var rand_tile_key: int = grid_data[coords.x][coords.y].keys().pick_random()
	collapsed_cell[rand_tile_key] = grid_data[coords.x][coords.y][rand_tile_key]
	grid_data[coords.x][coords.y] = collapsed_cell
	draw_cell(coords)

func draw_cell(coords: Vector2i) -> void:
	var cell = grid_data[coords.x][coords.y].values()[0]
	if cell["mesh_name"] == "-1":
		return

	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.mesh = load(tiles_path + cell["mesh_name"])
	mesh.position = Vector3(coords.x, 0, -coords.y)
	mesh.rotation.y = PI/2 * cell["rotation"]
	add_child(mesh)

func generate() -> void:
	message_collapsed.visible = false

	prepare_grid()

	position = Vector3(-size.x / 2.0, 0, size.y / 2.0)

	while not is_collapsed():
		var cell_pos = get_min_entropy_coords()
		collapse_at(cell_pos)
		propagate(cell_pos)
		await get_tree().create_timer(0.001).timeout

	message_collapsed.visible = true

func _ready() -> void:
	handle_rotations()
	handle_neighbors()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("regenerate"):
		message_start.visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		generate()

	if Input.is_action_just_pressed("menu"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and message_collapsed.visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if Input.is_action_pressed("quit"):
		get_tree().quit()
