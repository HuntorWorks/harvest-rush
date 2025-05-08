extends Node2D

var indicator = Sprite2D
var indicator_status = IndicatorStatus.OFF
var last_direction := Vector2.ZERO

const INDICATOR_OFFSET : float = 8 # Sprite is 8x8

enum IndicatorStatus { 
	OFF,
	ON
}

func _ready() -> void : 
	indicator = HuntorUtils.get_child_node_by_name(self, "Sprite2D")

func update_position(direction : Vector2) -> void : 
	var dir_normalized = direction.normalized()
	
	match dir_normalized :
		Vector2.UP : 
			indicator.offset = Vector2(-4, -4)
		Vector2.RIGHT : 
			indicator.offset = Vector2(4, 4)
		Vector2.LEFT : 
			indicator.offset = Vector2(-4, -4)
		Vector2.DOWN : 
			indicator.offset = Vector2(4, 4)
		

func get_indicator_status() -> IndicatorStatus : 
	return indicator_status
	
func set_indicator_status(status : IndicatorStatus) -> void : 
	indicator_status = status
	
func get_indicator_tile_position() -> Vector2 : 
	return global_position
