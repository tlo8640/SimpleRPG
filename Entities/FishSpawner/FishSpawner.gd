extends Node2D

var tilemap

# spawner variables
export var spawn_area : Rect2 = Rect2(50, 150, 700, 700)
export var max_fishes = 10
export var start_fishes = 5
var fish_count = 0
var fish_scene = preload("res://Entities/Fish/Fish.tscn")

# random number generator
var rng = RandomNumberGenerator.new()

func instance_fish():
	var fish = fish_scene.instance()
	add_child(fish)
	
	# place fish in a valid postion (lake)
	var valid_position = false
	while not valid_position:
		fish.position.x = spawn_area.position.x + rng.randf_range(0, spawn_area.size.x)
		fish.position.y = spawn_area.position.y + rng.randf_range(0, spawn_area.size.y)
		valid_position = test_position(fish.position)
		

func test_position(position: Vector2):
	# check if cell type is water
	var cell_coord = tilemap.world_to_map(position)
	var cell_type_id = tilemap.get_cellv(cell_coord)
	var water = (cell_type_id == tilemap.tile_set.find_tile_by_name("Water"))

	return water	

