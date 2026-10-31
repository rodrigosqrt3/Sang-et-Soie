extends Area2D

# The gold door at the top of the stairs: the way out into Paris.

var transition_in_progress: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if transition_in_progress or not body.is_in_group("player") or Dialogue.is_active():
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
		return

	# The door never silently ignores the player: Étienne says why Paris waits.
	var reason: String = get_locked_reason()
	if not reason.is_empty():
		Dialogue.bark("etienne", reason, 4.5)

func get_locked_reason() -> String:
	match Global.current_quest:
		Global.QUEST_TALK_TO_SMUGGLER:
			return "Not yet. The Belgian knows what Jacquet was carrying. I should hear it from him first."
		Global.QUEST_REPORT_FRAGMENT:
			return "The page is still in my coat. The Belgian will want to see it before I go anywhere."
		Global.QUEST_TALK_TO_MARGUERITE, Global.QUEST_GRAB_KEY:
			return "The way forward is not through this door. Marguerite knows what lies beneath the house."
		Global.QUEST_ENTER_SEWERS:
			return "The key is in my hand. The road runs under the Bal, not out of it."
		Global.QUEST_CHAPTER_TWO_COMPLETE:
			return "Paris has nothing more for me tonight."
	return ""
