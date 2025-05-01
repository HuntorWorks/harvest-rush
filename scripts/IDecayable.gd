extends TileMapLayer
class_name DecayableLayer

# Just handles the decaying of each layer. 

func decay_tile_at_position(cell_coords : Vector2i) -> void : 
	erase_cell(cell_coords)
