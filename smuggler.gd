extends Area2D

var is_player_nearby: bool = false

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
	# If there is at least one upgrade left to buy
	elif Global.dash_cooldown == 1.0 or Global.focus_drain_rate == 60.0 or Global.weapon_scale == Vector2(1.0, 1.0):
		var item_name = ""
		if Global.dash_cooldown == 1.0:
			item_name = "Silk Cravat (5 Francs)"
		elif Global.focus_drain_rate == 60.0:
			item_name = "Monocle Polish (7 Francs)"
		else:
			item_name = "Weighted Cane (10 Francs)"
		hub.show_dialogue("The Belgian Smuggler", "[E] Buy " + item_name + " | Wallet: " + str(Global.francs) + " Francs")
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
		var return_text: String = "You found it. The five francs belonged to the courier. The paper is worth considerably more."
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

func _on_button_b_pressed() -> void:
	if Global.current_quest == "talk_to_smuggler":
		Global.smuggler_trust -= 1
		Global.exposure += 2
		Global.current_quest = "enter_streets"
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

func open_shop() -> void:
	# Upgrade 1: Silk Cravat (Cost: 5 Francs)
	if Global.dash_cooldown == 1.0:
		if Global.francs >= 5:
			Global.francs -= 5
			Global.dash_cooldown = 0.6 # Permanently upgrade dash cooldown!
			Global.save_game()
			hub.show_dialogue(
				"The Belgian Smuggler", 
				"Smuggler: 'Ah, pure silk. Elegant and fast, Étienne. Excellent choice.'\n(Dash Cooldown permanently upgraded to 0.6s!)"
			)
			await get_tree().create_timer(3.0).timeout
			if is_player_nearby: update_shop_prompt()
		else:
			hub.show_dialogue(
				"The Belgian Smuggler", 
				"Smuggler: 'You don't have 5 Francs, Étienne. Come back later.'\nWallet: " + str(Global.francs) + " Francs"
			)
			
	# Upgrade 2: Monocle Polish (Cost: 7 Francs)
	elif Global.focus_drain_rate == 60.0:
		if Global.francs >= 7:
			Global.francs -= 7
			Global.focus_drain_rate = 35.0 # Drains focus almost twice as slow!
			Global.save_game()
			hub.show_dialogue(
				"The Belgian Smuggler", 
				"Smuggler: 'Ah, a finely polished lorgnette. Your gaze is sharper now, Étienne.'\n(Monocle focus drain permanently reduced to 35!)"
			)
			await get_tree().create_timer(3.0).timeout
			if is_player_nearby: update_shop_prompt()
		else:
			hub.show_dialogue(
				"The Belgian Smuggler", 
				"Smuggler: 'You don't have 7 Francs, Étienne. Come back later.'\nWallet: " + str(Global.francs) + " Francs"
			)
			
	# Upgrade 3: Weighted Cane (Cost: 10 Francs)
	elif Global.weapon_scale == Vector2(1.0, 1.0):
		if Global.francs >= 10:
			Global.francs -= 10
			Global.weapon_scale = Vector2(1.4, 1.4) # Permanently increase weapon size by 40%!
			
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				players[0].attack_pivot.scale = Global.weapon_scale
				
			Global.save_game()
			hub.show_dialogue(
				"The Belgian Smuggler", 
				"Smuggler: 'Lead-weighted enegreciated oak. Brutal.'\n(Weapon Size permanently upgraded by 40%!)"
			)
			await get_tree().create_timer(3.0).timeout
			if is_player_nearby: update_shop_prompt()
		else:
			hub.show_dialogue(
				"The Belgian Smuggler", 
				"Smuggler: 'You don't have 10 Francs, Étienne. Come back later.'\nWallet: " + str(Global.francs) + " Francs"
			)