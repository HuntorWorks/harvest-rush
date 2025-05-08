extends Node2D

@onready var managers : Node2D = HuntorUtilities.get_child_node_by_name(get_parent(), "Managers")
var game_manager : Node2D

var island_tilemap_layer : TileMapLayer
var farm_tilemap_layer : TileMapLayer

var TILEMAP_LAYERS : Array[TileMapLayer]

func _ready() -> void : 
	await get_tree().process_frame
	game_manager = managers.GAME_MANAGER
	island_tilemap_layer = HuntorUtilities.get_child_node_by_name(self, "IslandTilemapLayer")
	farm_tilemap_layer = HuntorUtilities.get_child_node_by_name(self, "FarmableTilemapLayer")
	
	TILEMAP_LAYERS.append(island_tilemap_layer)
	TILEMAP_LAYERS.append(farm_tilemap_layer)
	
	connect_to_signals()
func connect_to_signals() -> void : 
	pass
	
func irrigate_farmland_tile() -> void : 
	# if farmland, irrigate
	var tile_data = farm_tilemap_layer.get_cell_tile_data(farm_tilemap_layer.get_clicked_cell_coords())
	print("DATA: ", tile_data)
	
# Places farm tile.
func place_farmland_tile() -> void : 
	if farm_tilemap_layer.can_place_tile_on(farm_tilemap_layer.get_clicked_cell_coords(), island_tilemap_layer): 
		farm_tilemap_layer.set_cell(farm_tilemap_layer.get_clicked_cell_coords(), farm_tilemap_layer.FARMLAND_TILES_SOURCE, farm_tilemap_layer.FARMLAND_TILES_DICT.get("normal"))
		print("Placing Farm Tile")
	
func decay(amount_of_tiles_to_decay : int) -> void : 
	pass
		
func build_island_tile() -> void : 
	if island_tilemap_layer.get_clicked_cell_tile_data() != null : 
		print("Tile already there")
		return
	
	if is_island_build_tile_valid(island_tilemap_layer.get_clicked_cell_coords(), island_tilemap_layer) : 
		var rand_tile = randi_range(0, island_tilemap_layer.ISLAND_TILES_DICT.size() - 1)
		var atlas_coords = island_tilemap_layer.ISLAND_TILES_DICT[rand_tile]
		island_tilemap_layer.set_cell(island_tilemap_layer.get_clicked_cell_coords(), island_tilemap_layer.ISLAND_TILES_SOURCE_ID, atlas_coords)
	
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
	
