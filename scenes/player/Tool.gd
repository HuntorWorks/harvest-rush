extends Node2D
class_name Tool 

@export var sprite : Sprite2D
var current_tool := SelectedTool.NONE

var tool_sprite_region_rects : Dictionary = { 
	SelectedTool.HOE : Rect2(0, 16, 8, 8), 
	SelectedTool.PICKAXE : Rect2(8, 16, 8, 8),
	SelectedTool.AXE : Rect2(16, 16, 8, 8),
	SelectedTool.SCYTHE : Rect2(24, 16, 8, 8),
	SelectedTool.FISHING_ROD : Rect2(32, 16, 8, 8),
	SelectedTool.WATERING_CAN : Rect2(40, 16, 8, 8)
}

enum SelectedTool { 
	NONE,
	HOE,
	PICKAXE,
	FISHING_ROD,
	WATERING_CAN,
	SCYTHE,
	AXE
}

func _ready() -> void : 
	sprite.region_enabled = true

func _process(delta: float) -> void:
	if current_tool != SelectedTool.NONE : 
		sprite.visible = true
		sprite.region_rect = tool_sprite_region_rects.get(current_tool)
	else : 	
		sprite.visible = false
