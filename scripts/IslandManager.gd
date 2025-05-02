extends Node2D

@onready var managers : Node2D = HuntorUtilities.get_child_node_by_name(get_parent(), "Managers")
var game_manager : Node2D

var island_tilemap_layer : TileMapLayer

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

func connect_to_signals() -> void : 
	pass
	
func build_island_tile() -> void : 
	if island_tilemap_layer.get_clicked_cell_tile_data() != null : 
		print("Tile already there")
		return
	
	if is_island_build_tile_valid(island_tilemap_layer.get_clicked_cell_coords(), island_tilemap_layer) : 
		var rand_tile = randi_range(0, ISLAND_TILES_DICT.size() - 1)
		var atlas_coords = ISLAND_TILES_DICT[rand_tile]
		island_tilemap_layer.set_cell(island_tilemap_layer.get_clicked_cell_coords(), ISLAND_TILES_SOURCE_ID, atlas_coords)
	
## Checks if the clicked cell has at least 1 island tile in its neighbours
func is_island_build_tile_valid(cell_coords : Vector2i, tilemap_layer : TileMapLayer) -> bool : 
	var surrounding_cells = tilemap_layer.get_surrounding_cells(cell_coords)
	
	for cell in surrounding_cells : 
		var cell_data = tilemap_layer.get_cell_tile_data(cell)
		if cell_data != null : 
			return true
			
	return false
	
func can_place_island_tile() -> bool :
	return not island_tilemap_layer.is_tile_surrounded() and island_tilemap_layer.is_edge_tile()
	
