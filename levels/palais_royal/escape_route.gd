extends Area2D

func _ready() -> void:
	# Connect physics signal to detect when the player steps into the escape route
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Chamber cleared! Returning victorious to the Bal des Victimes.")
		Global.runs_completed += 1
		
		if Global.current_quest == Global.QUEST_ENTER_STREETS and Global.has_list_fragment:
			# The courier's envelope contains ten francs. The reward comes from
			# recovering information, never from killing guards.
			Global.francs += 10
			if Global.fragment_recovered_without_killing:
				Global.smuggler_trust += 1
			Global.current_quest = Global.QUEST_REPORT_FRAGMENT
			
		Global.save_game()
		Global.reset_active_run_state()
		Global.save_game()
		Global.transition_to_scene.call_deferred("res://levels/hub/bal_des_victimes.tscn")
