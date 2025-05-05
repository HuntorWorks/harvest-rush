extends CharacterBody2D

@export_category("Movement")
@export var move_speed : float

@export_category("Other")
@export var tool_node : Node2D
var has_tool = false

var direction := Vector2.ZERO

signal build_mode_request
signal build_island_tile_request
signal place_tile_request


func _process(delta : float) -> void :
	handle_input()
	get_movement_vector()

func _physics_process(delta: float) -> void:
	handle_movement()
	
func get_movement_vector() -> Vector2 : 
	direction.x = Input.get_axis("player_move_left", "player_move_right")
	direction.y = Input.get_axis("player_move_up", "player_move_down")
	
	return direction.normalized()
	
func handle_movement() -> void : 
	if not get_movement_vector() == Vector2.ZERO : 
		velocity = direction * move_speed
		move_and_slide()

func handle_input() -> void : 
	if Input.is_action_just_pressed("build_mode_toggle") : 
		build_mode_request.emit()
			
	if Input.is_action_just_pressed("mouse_action") : 
		build_island_tile_request.emit()
		
	if Input.is_action_just_pressed("mouse_action_2") : 
		place_tile_request.emit()

	if Input.is_action_just_pressed("tool_select_1") : 
		if tool_node != null : 
			tool_node.current_tool = tool_node.SelectedTool.HOE if tool_node.current_tool != tool_node.SelectedTool.HOE else tool_node.SelectedTool.NONE
			has_tool = true
		else : 
			print("Tool Node could not be found: ", tool_node)

func get_current_tool() -> Tool.SelectedTool:
	return tool_node.current_tool
