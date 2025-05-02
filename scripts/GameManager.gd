extends Node2D
class_name GameManager

@export var player : CharacterBody2D
@export var island_manager : Node2D

var island_decay_timer : Timer = Timer.new()
const ISLAND_DECAY_TIME := 600.0
const ISLAND_DECAY_RATE := 3

var build_mode = false

func _ready() -> void:
	subscribe_to_signals()
	init_decay_timer()
	
func _process(delta: float) -> void:
	pass
	
func subscribe_to_signals() -> void : 
	island_decay_timer.connect("timeout", _on_island_decay_timer_timeout)
	
	player.connect("build_mode_request", _build_mode_request_signal)
	player.connect("build_island_tile_request", _build_island_tile_request_signal)
	player.connect("place_tile_request", _place_tile_request_signal)
	
func init_decay_timer() -> void : 
	add_child(island_decay_timer)
	island_decay_timer.start(ISLAND_DECAY_TIME)

func _on_island_decay_timer_timeout() -> void : 
	island_manager.decay(ISLAND_DECAY_RATE)
	
func _build_mode_request_signal() -> void : 
	if not build_mode : 
		build_mode = true
	else : 
		build_mode = false
	print("Build Mode: ", build_mode)

func _build_island_tile_request_signal() -> void : 
	if build_mode : 
		island_manager.build_island_tile()
		
func _place_tile_request_signal() -> void : 
	if build_mode : 
		island_manager.place_tile()
