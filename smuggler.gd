extends Area2D

var is_player_nearby: bool = false
var shop_offer_a: String = ""
var shop_offer_b: String = ""

const UPGRADE_COST: int = 5

@onready var hub: Node2D = get_parent()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if is_player_nearby and Input.is_action_just_pressed("interact"):
		handle_interaction()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		update_shop_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		hub.hide_dialogue()

func update_shop_prompt() -> void:
	if Global.current_quest == "talk_to_smuggler":
		hub.show_dialogue("The Belgian Smuggler", "[E] Talk to the Smuggler")
	elif Global.current_quest == "report_fragment":
		hub.show_dialogue("The Belgian Smuggler", "[E] Discuss the recovered fragment")
	elif Global.current_quest == "campaign_complete":
		hub.show_dialogue("The Belgian Smuggler", "[E] Ask about Théodore's cipher")
	elif not get_available_upgrades().is_empty():
		hub.show_dialogue("The Belgian Smuggler", "[E] Browse alterations | Wallet: " + str(Global.francs) + " Francs")
	else:
		hub.show_dialogue("The Belgian Smuggler", "'I have nothing else for you, Étienne. Be careful.'\nWallet: " + str(Global.francs) + " Francs")

func handle_interaction() -> void:
	if Global.current_quest == "talk_to_smuggler":
		hub.show_dialogue(
			"The Belgian Smuggler", 
			"A courier limped into the Palais-Royal with a torn page from the lists. Then the Guard arrived. He dropped it somewhere in the arcades. Bring me that page, and I will give you the name of someone who knows the passages under Paris."
		)
		hub.show_choices(
			"'Then I owe you a favor.'",
			"Touch the cane. 'Give me the name now.'",
			self
		)
	elif Global.current_quest == "report_fragment":
		var return_text: String = "You found it. The ten francs belonged to the courier. The paper is worth considerably more."
		if Global.fragment_recovered_without_killing:
			return_text += " No bodies? Perhaps the coat is not entirely decorative."
		else:
			return_text += " The Guard is counting its dead. By dawn, they will be counting descriptions of your coat."
		hub.show_dialogue(
			"The Belgian Smuggler", 
			return_text
		)
		hub.show_choices(
			"Keep the names covered. Show him the seal.",
			"Hand him the page.",
			self
		)
	elif Global.current_quest == "campaign_complete":
		hub.show_dialogue(
			"The Belgian Smuggler",
			"Your brother is not waiting to be rescued. Printers have been warning the people named on those pages. If the cipher is his, he may be closer to the source than either of us."
		)
	# Default Shop Mode (Open standard upgrades)
	else:
		open_shop()

# =================══════════════════════════════════════════
# DIALOGUE CHOICE CALLBACKS (Process the player's decisions!)
# =================══════════════════════════════════════════

func _on_button_a_pressed() -> void:
	if Global.current_quest == "talk_to_smuggler":
		Global.smuggler_debt += 1
		Global.smuggler_trust += 1
		Global.current_quest = "enter_streets"
		Global.begin_palais_excursion()
		Global.save_game()
		hub.show_dialogue("The Belgian Smuggler", "'Good. Debts survive longer than men. Use the gold door and look for red wax.'")
		await get_tree().create_timer(4.0).timeout
		if is_player_nearby: update_shop_prompt()
		
	elif Global.current_quest == "report_fragment":
		Global.current_quest = "talk_to_marguerite"
		Global.save_game()
		hub.show_dialogue("The Belgian Smuggler", "'Good. A secret shown to one man is already gossip. Marguerite Colbert knows the gate used by the old escape network. Ask her what remains beneath this house.'")
		await get_tree().create_timer(4.0).timeout
		if is_player_nearby: update_shop_prompt()
	elif not shop_offer_a.is_empty():
		purchase_upgrade(shop_offer_a)

func _on_button_b_pressed() -> void:
	if Global.current_quest == "talk_to_smuggler":
		Global.smuggler_trust -= 1
		Global.exposure += 2
		Global.current_quest = "enter_streets"
		Global.begin_palais_excursion()
		Global.save_game()
		hub.show_dialogue("The Belgian Smuggler", "'That cane frightens clerks and children. I am neither. The page is in the arcades. Go make your noise somewhere else.'")
		await get_tree().create_timer(4.0).timeout
		if is_player_nearby: update_shop_prompt()
		
	elif Global.current_quest == "report_fragment":
		Global.smuggler_trust += 1
		Global.exposure += 1
		Global.current_quest = "talk_to_marguerite"
		Global.save_game()
		hub.show_dialogue("The Belgian Smuggler", "'Vauclaire. So your ghost has a family. I will remember that you trusted me. Speak to Marguerite; her dead Madame once used a gate beneath this house.'")
		await get_tree().create_timer(4.0).timeout
		if is_player_nearby: update_shop_prompt()
	elif not shop_offer_b.is_empty():
		purchase_upgrade(shop_offer_b)
	else:
		hub.hide_dialogue()

func open_shop() -> void:
	var available_upgrades: Array[String] = get_available_upgrades()
	if available_upgrades.is_empty():
		shop_offer_a = ""
		shop_offer_b = ""
		hub.show_dialogue(
			"The Belgian Smuggler",
			"'Nothing else tonight, Étienne. Even decadence has an inventory.'\nWallet: " + str(Global.francs) + " Francs"
		)
		return

	shop_offer_a = available_upgrades[0]
	shop_offer_b = available_upgrades[1] if available_upgrades.size() > 1 else ""
	hub.show_dialogue(
		"The Belgian Smuggler",
		"Choose what kind of survivor you intend to be. Each alteration costs " + str(UPGRADE_COST) + " francs.\nWallet: " + str(Global.francs) + " Francs"
	)
	var option_b_text: String = get_upgrade_name(shop_offer_b) if not shop_offer_b.is_empty() else "Not tonight."
	hub.show_choices(get_upgrade_name(shop_offer_a), option_b_text, self)

func get_available_upgrades() -> Array[String]:
	var upgrades: Array[String] = []
	if Global.dash_cooldown >= 1.0:
		upgrades.append("dash")
	if Global.focus_drain_rate >= 60.0:
		upgrades.append("focus")
	if Global.weapon_scale == Vector2(1.0, 1.0):
		upgrades.append("cane")
	return upgrades

func get_upgrade_name(upgrade_id: String) -> String:
	match upgrade_id:
		"dash":
			return "Silk Cravat — quicker recovery (5 F)"
		"focus":
			return "Monocle Polish — longer Regard (5 F)"
		"cane":
			return "Weighted Cane — broader strike (5 F)"
	return "Not tonight."

func purchase_upgrade(upgrade_id: String) -> void:
	if Global.francs < UPGRADE_COST:
		hub.show_dialogue(
			"The Belgian Smuggler",
			"'Taste is expensive. Return when your purse agrees.'\nWallet: " + str(Global.francs) + " Francs"
		)
		return

	Global.francs -= UPGRADE_COST
	var result_text: String = ""
	match upgrade_id:
		"dash":
			Global.dash_cooldown = 0.6
			result_text = "The silk settles around your throat. Movement feels less costly."
		"focus":
			Global.focus_drain_rate = 35.0
			result_text = "The polished lens catches details that previously escaped you."
		"cane":
			Global.weapon_scale = Vector2(1.4, 1.4)
			result_text = "Lead shifts inside the cane. Elegance acquires weight."
			var players: Array[Node] = get_tree().get_nodes_in_group("player")
			if not players.is_empty():
				var player: Node = players[0]
				var attack_pivot_node: Node2D = player.get_node_or_null("AttackPivot") as Node2D
				if attack_pivot_node != null:
					attack_pivot_node.scale = Global.weapon_scale
		_:
			Global.francs += UPGRADE_COST
			return

	shop_offer_a = ""
	shop_offer_b = ""
	Global.save_game()
	hub.show_dialogue(
		"The Belgian Smuggler",
		result_text + "\nWallet: " + str(Global.francs) + " Francs"
	)