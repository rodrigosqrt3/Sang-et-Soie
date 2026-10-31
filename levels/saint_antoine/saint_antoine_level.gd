extends DistrictLevel

# Act II rooms. The raid guards only exist once the police have closed in on
# the hidden press.

@export_enum("street", "workshop", "printshop") var sector_id: String = "street"

func on_level_ready() -> void:
	if sector_id == "printshop" and Global.current_quest not in [Global.QUEST_REACH_PRINTSHOP, Global.QUEST_ESCAPE_SAINT_ANTOINE]:
		for guard_name in ["GuardRaidA", "GuardRaidB", "GuardRaidC"]:
			remove_guard(guard_name)
	update_status()
	show_arrival_message.call_deferred()

func show_arrival_message() -> void:
	await get_tree().create_timer(0.5).timeout
	if sector_id == "street" and Global.current_quest == Global.QUEST_MEET_LUCILE:
		Dialogue.bark_conversation("saint_antoine_arrival", 6.5)
	elif sector_id == "workshop" and Global.current_quest == Global.QUEST_SEARCH_WORKSHOP:
		Dialogue.bark_conversation("workshop_arrival", 6.5)
	elif sector_id == "printshop" and Global.current_quest == Global.QUEST_REACH_PRINTSHOP:
		Dialogue.bark_conversation("printshop_arrival", 6.5)

func _process(_delta: float) -> void:
	update_status()

func update_status() -> void:
	match Global.current_quest:
		Global.QUEST_MEET_LUCILE:
			set_status("In a worker's smock, silk does not show. Walk slowly among the crowds.")
		Global.QUEST_SEARCH_WORKSHOP:
			set_status("East, through the shuttered workshop.")
		Global.QUEST_REACH_PRINTSHOP:
			set_status("The raid is coming. Decide before the courtyards are sealed.", Color("E07A5F"))
		Global.QUEST_ESCAPE_SAINT_ANTOINE:
			set_status("Get out through the dyers' courtyard to the east.", Color("E0C27A"))
		_:
			set_status("")
