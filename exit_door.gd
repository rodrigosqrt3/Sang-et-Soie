extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Chamber cleared! Returning victorious to the Bal des Victimes.")
		Global.runs_completed += 1
		
		# Advance quest state if we cleared the streets!
		if Global.current_quest == "enter_streets":
			Global.current_quest = "report_to_smuggler"
			
		get_tree().change_scene_to_file.call_deferred("res://bal_des_victimes.tscn")