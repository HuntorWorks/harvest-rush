extends Node2D
class_name Managers

var GAME_MANAGER : Node2D

func _ready():
	GAME_MANAGER = HuntorUtilities.get_child_node_by_name(self, "GameManager")

func get_class_name(): 
	return "Managers"
