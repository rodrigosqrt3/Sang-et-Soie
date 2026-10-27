extends Node2D
class_name DistrictArrivalPoint

@export var spawn_id: String = "default"

func _ready() -> void:
	add_to_group("arrival_points")