extends Node

var player : CharacterBody2D
var island_manager : Node2D
var game_manager : Node2D

func _ready() -> void:
	player = get_parent().player
	island_manager = get_parent().island_manager
	game_manager = get_parent().game_manager
	
	connect_to_signals()
	
func connect_to_signals() -> void : 
	player.connect("build_mode_request", Callable(game_manager, "_toggle_build_mode"))
	player.connect("interact_request", Callable(self, "_on_interact_tile_request"))
		
func _on_place_tile_request() -> void : 
	if game_manager.build_mode and player.get_current_tool() == Tool.SelectedTool.HOE: 
		island_manager.place_tile()

func _on_interact_request() -> void : 
	interact_tile()

func interact_tile() -> void : 
	if can_interact(): 
		if game_manager.build_mode:
			if player.get_current_tool() == Tool.SelectedTool.HOE : 
				island_manager.place_farmland_tile() 
				
			island_manager.build_island_tile()
			
		if player.get_current_tool() == Tool.SelectedTool.WATERING_CAN : 
			island_manager.irrigate_farmland_tile()
	# if not in build mode, plant seeds in farmland, if seeds water, crop stage, harvest
	
func can_interact() -> bool : 
	var tilemap : TileMapLayer = island_manager.island_tilemap_layer
	var current_player_tile = tilemap.local_to_map(tilemap.to_local(player.global_position)) # Vec2i
	var clicked_tile = tilemap.get_clicked_cell_coords() # Vec2
	
	if clicked_tile.distance_to(current_player_tile) <= 1 :
		return true
		
	return false
