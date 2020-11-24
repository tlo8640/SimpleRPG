extends Node2D

# nodes reference
var tilemap
var tree_tilemap
var house
var no_spawn_area

# spawner variables
export var spawn_area : Rect2 = Rect2(50, 150, 700, 700)
export var max_skeletons = 80
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
	var grass_or_sand = (cell_type_id == tilemap.tile_set.find_tile_by_name("Grass")) || \
			(cell_type_id == tilemap.tile_set.find_tile_by_name("Sand"))
	
	# check for tree
	#cell_coord = tilemap.world_to_map(position)
	#cell_type_id = tilemap.get_cellv(cell_coord)
	var no_trees = (cell_type_id != tilemap.tile_set.find_tile_by_name("Tree"))
	
		# check for house
	var house_pos = house.get_position()
	
	#print("house_pos: " + str(house_pos))
	#print("no_spawn_size.margin_top: " + str(no_spawn_area.margin_top))
	#print("no_spawn_size.margin_left: " + str(no_spawn_area.margin_left))
	#print("no_spawn_size.margin_bottom: " + str(no_spawn_area.margin_bottom))
	#print("no_spawn_size.margin_right: " + str(no_spawn_area.margin_right))
	
	var no_inhouse_spawn = ( ! (\
			position.x > (house_pos.x + no_spawn_area.margin_left) && \
			position.x < (house_pos.x + no_spawn_area.margin_right) && \
			position.y > (house_pos.y + no_spawn_area.margin_top) && \
			position.y < (house_pos.y + no_spawn_area.margin_bottom)))
	
	print("skeleton_count" + str(skeleton_count))
	if ! no_inhouse_spawn:
		print("INHOUSE")
	else:
		print("NOT inhouse")
	
	# position is valid if both values are true 
	return grass_or_sand and no_trees and no_inhouse_spawn
	
func _ready():
	# get tilemaps refernce
	tilemap = get_tree().root.get_node("Root/TileMap")
	tree_tilemap = get_tree().root.get_node("Root/Tree TileMap")
	house = get_tree().root.get_node("Root/House")
	no_spawn_area = get_tree().root.get_node("Root/House/NoSpawnArea")
	
	# initialize random numbe rgenerator
	rng.randomize()
	
	# create skeleton
	if not get_parent().load_saved_game:
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
	
func to_dictionary():
	var skeletons = []
	for node in get_children():
		if node.name.find("Skeleton") >= 0:
			skeletons.append(node.to_dictionary())
	return skeletons

func from_dictionary(data):
	skeleton_count = data.size()
	for skeleton_data in data:
		var skeleton = skeleton_scene.instance()
		skeleton.from_dictionary(skeleton_data)
		add_child(skeleton)
		skeleton.get_node("Timer").start()
		
		# connect skeleton death signal to spawner
		skeleton.connect("death", self, "_on_Skeleton_death")
