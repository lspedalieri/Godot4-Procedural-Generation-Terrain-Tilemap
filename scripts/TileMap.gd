extends Node2D


@export var noise_height_text: NoiseTexture2D
@export var noise_tree_text: NoiseTexture2D

@onready var tile_map: TileMap = $TileMap
@onready var camera_2d: Camera2D = $Player/Camera2D

var noise: Noise
var tree_noise: Noise
var width: int = 200
var height: int = 200
var noise_val_arr: Array = []
var source_id = 0

#LAYERS
var water_layer: int = 0
var ground_1_layer: int = 1
var ground_2_layer: int = 2
var cliff_layer: int = 3
var environment_layer: int = 4


var water_atlas = Vector2i(0, 1)
var land_atlas = Vector2i(0, 0)
var grass_atlas = [Vector2i(1, 0),Vector2i(2, 0),Vector2i(3, 0),Vector2i(4, 0),Vector2i(5, 0)]
var palm_tree_atlas = [Vector2i(12, 2),Vector2i(15, 2)]
var oak_tree_atlas = Vector2i(15, 6)

var terrain_grass_int: int = 1
var terrain_sand_int: int = 3
var terrain_cliff_int: int = 4
var grass_tiles_arr: Array = []
var sand_tiles_arr: Array = []
var cliff_tiles_arr: Array = []


func _ready():
	noise = noise_height_text.noise
	tree_noise = noise_tree_text.noise
	generate_world()


func generate_world():
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			var noise_val: float = noise.get_noise_2d(x, y)
			var tree_noise_val: float = tree_noise.get_noise_2d(x, y)
			noise_val_arr.append(tree_noise_val)
			#placing ground
			if noise_val > 0.0:
				if noise_val > 0.05 and noise_val < 0.17 and tree_noise_val > 0.8:
					tile_map.set_cell(environment_layer, Vector2(x, y), source_id, palm_tree_atlas.pick_random())
				if noise_val > 0.2:
					if noise_val > 0.25:
						if noise_val < 0.35 and tree_noise_val > 0.8:
							tile_map.set_cell(environment_layer, Vector2(x, y), source_id, oak_tree_atlas)
						tile_map.set_cell(ground_2_layer, Vector2(x, y), source_id, grass_atlas.pick_random())
					if noise_val > 0.4:
						cliff_tiles_arr.append(Vector2i(x,y))
					#grass
					grass_tiles_arr.append(Vector2i(x,y))
				#sand
				sand_tiles_arr.append(Vector2i(x,y))
			#water everywhere else
			tile_map.set_cell(water_layer, Vector2(x, y), source_id, water_atlas)
	tile_map.set_cells_terrain_connect(ground_1_layer, sand_tiles_arr, terrain_sand_int, 0)
	tile_map.set_cells_terrain_connect(ground_1_layer, grass_tiles_arr, terrain_grass_int, 0)
	tile_map.set_cells_terrain_connect(cliff_layer, cliff_tiles_arr, terrain_cliff_int, 0)
	print(noise_val_arr.min())
	print(noise_val_arr.max())


func _input(event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera_2d.zoom.x - 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
	if Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera_2d.zoom.x + 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
