class_name WFCGenerator

extends Node

@export var grid : GridMap;

var bound: Vector3i;

func _ready() -> void:
	var lib : MeshLibrary = grid.mesh_library;
	grid.set_cell_item(Vector3i(0, 0, 0), lib.find_item_by_name("GrassCorner"), 0)
	

func _process(_delta: float) -> void:
	pass
