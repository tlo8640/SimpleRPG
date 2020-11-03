extends Node2D

# nodes reference
var tilemap
var tree_tilemap

# spawner variables
export var spawn_area : Rect2 = Rect2(50, 150, 700, 700)
export var max_skeletons = 40
export var start_skeletons = 10
var skeleton_count = 0
var skeleton_scene = preload("res://Entities/Skeleton/Skeleton.tscn")

# random
var rng = RandomNumberGenerator.new()

func instance_skeleton():
	# instance scene
	var skeleton = skeleton_scene.instance()
	add_child(skeleton)
	# connect skeleton death signal to the spawner
	skeleton.connect("death", self, "_on_Skeleton_death")
	
	# place skeleton 
	var valid_position = false
	while not valid_position:
		skeleton.position.x  = spawn_area.position.x + rng.randf_range(0, spawn_area.size.x)
		skeleton.position.y  = spawn_area.position.y + rng.randf_range(0, spawn_area.size.y)
		valid_position = test_position(skeleton.position)
	
	# play animation
	skeleton.arise()
	
func test_position(position : Vector2):
	# check for valid position of skeleton (grass or sand)
	var cell_coord = tilemap.world_to_map(position)
	var cell_type_id = tilemap.get_cellv(cell_coord)
	var grass_or_sand = (cell_type_id == tilemap.tile_set.find_tile_by_name("Grass")) || (cell_type_id == tilemap.tile_set.find_tile_by_name("Sand"))
	
	# check for tree
	cell_coord = tilemap.world_to_map(position)
	cell_type_id = tilemap.get_cellv(cell_coord)
	var no_trees = (cell_type_id != tilemap.tile_set.find_tile_by_name("Tree"))
	
	# position is valid if both values are true 
	return grass_or_sand and no_trees
	
func _ready():
	# get tilemaps refernce
	tilemap = get_tree().root.get_node("Root/TileMap")
	tree_tilemap = get_tree().root.get_node("Root/Tree TileMap")
	
	# initialize random numbe rgenerator
	rng.randomize()
	
	# create skeleton
	for i in range(start_skeletons):
		instance_skeleton()
	skeleton_count = start_skeletons

func _on_Timer_timeout():
	# every second
	if skeleton_count < max_skeletons:
		instance_skeleton()
		skeleton_count += 1

func _on_Skeleton_death():
	skeleton_count -= 1
	