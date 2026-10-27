extends Area2D

var transition_in_progress: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if transition_in_progress or not body.is_in_group("player"):
		return

	if Global.current_quest == Global.QUEST_ENTER_STREETS:
		transition_in_progress = true
		Global.travel_to_scene("res://levels/palais_royal/palais_garden.tscn", "")
		return

	if Global.current_quest == Global.QUEST_CHAPTER_ONE_COMPLETE:
		transition_in_progress = true
		Global.begin_saint_antoine_excursion()
		Global.travel_to_scene("res://levels/saint_antoine/faubourg_street.tscn", "bal_entry")
		return

	if Global.current_quest in [Global.QUEST_MEET_LUCILE, Global.QUEST_SEARCH_WORKSHOP, Global.QUEST_REACH_PRINTSHOP, Global.QUEST_ESCAPE_SAINT_ANTOINE]:
		transition_in_progress = true
		if not Global.active_run:
			Global.begin_active_run()
		Global.travel_to_scene("res://levels/saint_antoine/faubourg_street.tscn", "bal_entry")
