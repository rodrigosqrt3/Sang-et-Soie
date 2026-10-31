extends DistrictLevel

# The quarries beneath the rue d'Enfer: Madame's passage, the old well, and the
# copyist's chamber where Mâchefer guards the ledger.

@export_enum("passage", "well", "chamber") var sector_id: String = "passage"

const PHASE_NAMES: Array[String] = ["", "STEADY", "ENRAGED", "DESPERATE"]

func on_level_ready() -> void:
	match sector_id:
		"passage":
			set_status("Somewhere ahead, a lamp burns where no lamp should.")
			if not Global.has_flag("seen:quarry_descent"):
				play_conversation.call_deferred("quarry_descent")
		"well":
			set_status("The air turns cold above the water. Cross by the old bridge.")
		"chamber":
			set_status("Mâchefer keeps the copyist's ledger. Take it from him.", Color("E07A5F"))
			confront_machefer.call_deferred()

func play_conversation(conversation_id: String) -> void:
	await get_tree().create_timer(0.6).timeout
	if not Dialogue.is_active():
		Dialogue.start(conversation_id)

# Mâchefer speaks once in full; on later attempts he only snarls.
func confront_machefer() -> void:
	await get_tree().create_timer(0.6).timeout
	if Dialogue.is_active():
		return
	if Global.has_flag("seen:machefer_meets"):
		Dialogue.bark("machefer", "Back again, Vauclaire? The Captain will be pleased. He likes a full ledger.", 4.0)
	else:
		Dialogue.start("machefer_meets")

func _process(_delta: float) -> void:
	if sector_id != "chamber" or hud == null:
		return
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	if bosses.is_empty():
		hud.call("hide_boss")
		set_status("The ledger lies where Mâchefer fell.", Color("E0C27A"))
		return
	var boss: Node = bosses[0]
	var phase: int = clampi(int(boss.get("phase")), 1, 3)
	hud.call("show_boss", "MÂCHEFER  ·  " + PHASE_NAMES[phase], float(boss.get("current_health")), 7.0)
