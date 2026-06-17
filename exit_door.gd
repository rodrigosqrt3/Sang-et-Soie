extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# ONLY allow the player to enter the streets if they accepted the quest!
		if Global.current_quest == "enter_streets":
			print("Leaving the Bal des Victimes... Heading to Paris streets.")
			get_tree().change_scene_to_file.call_deferred("res://world.tscn")
		else:
			# The door is locked!
			print("The door is locked. Talk to the Smuggler first.")