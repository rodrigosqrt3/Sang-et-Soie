extends Area2D

func _ready() -> void:
	# Connect physics signal to detect when the player steps into the exit door
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Leaving the Bal des Victims... Heading to Paris streets.")
		# CHANGE: Safely defer changing the scene outside the physics step
		get_tree().change_scene_to_file.call_deferred("res://world.tscn")