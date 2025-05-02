class_name BaseTileMapLayer
extends TileMapLayer

# Just handles the decaying of each layer. 
var edge_tiles_ArrayList : Array[Vector2i]

func decay_tile_at_position(cell_coords : Vector2i) -> void : 
	erase_cell(cell_coords)

func get_edge_tiles() -> Array[Vector2i] : 
	var used_cells = get_used_cells()
	edge_tiles_ArrayList.clear()
	
	for i in range(used_cells.size()) : 
		if not is_tile_surrounded_at_mouse_click() : 
			edge_tiles_ArrayList.append(used_cells[i])
				
	return edge_tiles_ArrayList

func is_tile_surrounded(cell_coords : Vector2i) -> bool :
	var surrounding_cells = get_surrounding_cells(cell_coords)
	
	for cell in surrounding_cells : 
		if not get_cell_tile_data(cell) : 
			return false
	
	return true
	
func is_tile_surrounded_at_mouse_click() -> bool :
	return is_tile_surrounded(get_clicked_cell_coords()) 
	
	
func is_edge_tile() -> bool : 
	get_edge_tiles()
	for tile_cell_coords in edge_tiles_ArrayList : 
		if tile_cell_coords == get_clicked_cell_coords() : 
			return true

	return false
	
func get_clicked_cell_coords() -> Vector2i : 
	var mouse_pos = HuntorUtilities.get_mouse_world_position2D(HuntorUtilities.find_node_by_type(get_parent().get_parent(), "Camera2D"))
	return local_to_map(mouse_pos)
	
func get_clicked_cell_tile_data(cell_coords : Vector2i = get_clicked_cell_coords()) -> TileData : 
	return get_cell_tile_data(cell_coords)
