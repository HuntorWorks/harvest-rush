extends Node2D

@onready var managers : Node2D = HuntorUtilities.get_child_node_by_name(get_parent(), "Managers")
var game_manager : Node2D

var island_tilemap_layer : TileMapLayer
var edge_tiles_ArrayList : Array[Vector2i]
var is_edge_tile := false

const ISLAND_TILES_SOURCE_ID = 0
const ISLAND_TILES_DICT : Dictionary = {
	0 : Vector2i(0, 0),
	1 : Vector2i(1, 0), 
	2 : Vector2i(2, 0), 
	3 : Vector2i(3, 0),
	4 : Vector2i(0, 1), 
	5 : Vector2i(1, 1),
	6 : Vector2i(2, 1),
	7 : Vector2i(3, 1) 	
}

func _ready() -> void : 
	await get_tree().process_frame
	game_manager = managers.GAME_MANAGER
	island_tilemap_layer = HuntorUtilities.get_child_node_by_name(self, "IslandTilemapLayer")
	connect_to_signals()
	#island_decay_timer.start()

func connect_to_signals() -> void : 
	pass
	
## Function that detects if the tile clicked is an interior tile or not
##@return returns true if it is an interior tile false if not
func has_all_surrounding_tiles(cell_coords : Vector2i, tilemap_layer : TileMapLayer) -> bool : 
	var surrounding_cells = tilemap_layer.get_surrounding_cells(cell_coords)
	
	for cell in surrounding_cells : 
		var cell_data = tilemap_layer.get_cell_tile_data(cell)
		if cell_data == null : 
			return false
	
	return true
	
func get_edge_tiles(tilemap_layer : TileMapLayer) -> Array[Vector2i] : 
	edge_tiles_ArrayList.clear()
	var used_cells = tilemap_layer.get_used_cells()
	
	for i in range(used_cells.size()) : 
		is_edge_tile = false
		if not has_all_surrounding_tiles(used_cells[i], tilemap_layer) : 
			edge_tiles_ArrayList.append(used_cells[i])
				
	return edge_tiles_ArrayList

func build_island_tile() -> void : 
	#place island tile at the edge of the island
	var mouse_pos = HuntorUtilities.get_mouse_world_position2D(HuntorUtilities.find_node_by_type(get_parent(), "Camera2D"))
	var clicked_cell_coords : Vector2i = island_tilemap_layer.local_to_map(mouse_pos)
	var clicked_cell_data = island_tilemap_layer.get_cell_tile_data(clicked_cell_coords)
	
	if clicked_cell_data != null : 
		print("Tile already there")
		return
	
	if can_place_island_tile(clicked_cell_coords, island_tilemap_layer) : 
		var rand_tile = randi_range(0, ISLAND_TILES_DICT.size() - 1)
		var atlas_coords = ISLAND_TILES_DICT[rand_tile]
		island_tilemap_layer.set_cell(clicked_cell_coords, ISLAND_TILES_SOURCE_ID, atlas_coords)
	
## Checks if the clicked cell has at least 1 island tile in its neighbours
func is_island_build_tile_valid(cell_coords : Vector2i, tilemap_layer : TileMapLayer) -> bool : 
	var surrounding_cells = tilemap_layer.get_surrounding_cells(cell_coords)
	
	for cell in surrounding_cells : 
		var cell_data = tilemap_layer.get_cell_tile_data(cell)
		if cell_data != null : 
			return true
			
	return false
	
func can_place_island_tile(cell_coords : Vector2i, tilemap_layer : TileMapLayer) -> bool :
	return not has_all_surrounding_tiles(cell_coords, tilemap_layer) and is_island_build_tile_valid(cell_coords, tilemap_layer)
	
func decay_island(num_tiles_to_decay : int) -> void : 
	for i in range(num_tiles_to_decay) : 
		var edge_tiles = get_edge_tiles(island_tilemap_layer)
		var edge_tile_selected_index = randi_range(0, edge_tiles.size())
		island_tilemap_layer.erase_cell(edge_tiles[edge_tile_selected_index])
		edge_tiles.pop_at(edge_tile_selected_index)
