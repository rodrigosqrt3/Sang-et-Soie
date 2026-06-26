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
	elif Global.current_quest == "report_to_smuggler":
		hub.show_dialogue("The Belgian Smuggler", "[E] Report your victory")
	elif Global.dash_cooldown == 1.0:
		hub.show_dialogue("The Belgian Smuggler", "[E] Open Shop | Wallet: " + str(Global.francs) + " Francs")
	else:
		hub.show_dialogue("The Belgian Smuggler", "'I have nothing else for you, Étienne. Be careful.'")

func handle_interaction() -> void:
	# Quest Step 1: Smuggler gives the first mission (Offers Choice!)
	if Global.current_quest == "talk_to_smuggler":
		hub.show_dialogue(
			"The Belgian Smuggler", 
			"Étienne... Looking for your brother Théodore, are you? I might have a lead on that list... but it will cost you. First, clear the Republican Guard patrole out in the alley."
		)
		# Trigger the UI choice box!
		hub.show_choices(
			"Sigh... 'Very well. I will do it.'", # Option A
			"Step closer. 'Tell me now, or I will use this cane.'", # Option B
			self
		)
	# Quest Step 2: Reporting the victory (Offers Choice!)
	elif Global.current_quest == "report_to_smuggler":
		hub.show_dialogue(
			"The Belgian Smuggler", 
			"Ah, you made it back! The alley is quiet. I suppose the Guard won't be bothering us anymore. For your reward..."
		)
		hub.show_choices(
			"'Thank you. What is the lead?'", # Option A
			"Snatch the coins. 'My brother, Smuggler. Now.'", # Option B
			self
		)
	# Default Shop Mode (Open standard upgrades)
	else:
		open_shop()

# =================══════════════════════════════════════════
# DIALOGUE CHOICE CALLBACKS (Process the player's decisions!)
# =================══════════════════════════════════════════

# Triggered when player chooses OPTION A (Polite / Indifferent Dandy)
func _on_button_a_pressed() -> void:
	if Global.current_quest == "talk_to_smuggler":
		Global.current_quest = "enter_streets"
		
		Global.save_game()
		
		hub.show_dialogue("The Belgian Smuggler", "Smuggler: 'Splendid. Go through the golden door when you are ready. Do try not to get blood on that fine silk coat.'")
		await get_tree().create_timer(4.0).timeout
		if is_player_nearby: update_shop_prompt()
		
	elif Global.current_quest == "report_to_smuggler":
		Global.francs += 5
		Global.current_quest = "talk_to_marguerite"
		
		# ADICIONE ESTA LINHA:
		Global.save_game()
		
		hub.show_dialogue("The Belgian Smuggler", "Smuggler: 'Here are 5 Francs. As for the lead... talk to Marguerite Colbert. She knows about the old sewer gate. Go.'")
		await get_tree().create_timer(4.0).timeout
		if is_player_nearby: update_shop_prompt()

# Triggered when player chooses OPTION B (Aggressive / Impatient)
func _on_button_b_pressed() -> void:
	if Global.current_quest == "talk_to_smuggler":
		Global.current_quest = "enter_streets"
		
		# ADICIONE ESTA LINHA:
		Global.save_game()
		
		# The Smuggler reacts defensively to the threat!
		hub.show_dialogue("The Belgian Smuggler", "Smuggler: 'Woah, easy dandy! Put the lead-cane away. Do the job first, then we talk. The door is unlocked.'")
		await get_tree().create_timer(4.0).timeout
		if is_player_nearby: update_shop_prompt()
		
	elif Global.current_quest == "report_to_smuggler":
		Global.francs += 5
		Global.current_quest = "talk_to_marguerite"
		
		# ADICIONE ESTA LINHA:
		Global.save_game()
		
		# The Smuggler is annoyed by the rudeness
		hub.show_dialogue("The Belgian Smuggler", "Smuggler: 'Ugh, no need to snatch! Here are 5 Francs. The lead is Marguerite. She knows how to open the sewer gate. Now leave me.'")
		await get_tree().create_timer(4.0).timeout
		if is_player_nearby: update_shop_prompt()

# =================══════════════════════════════════════════
# UPGRADE SHOP LOGIC
# =================══════════════════════════════════════════
# ===========================================================================
# UPGRADE SHOP LOGIC
# ===========================================================================
func open_shop() -> void:
	# Upgrade 1: Silk Cravat (Cost: 5 Francs)
	if Global.dash_cooldown == 1.0:
		if Global.francs >= 5:
			Global.francs -= 5
			Global.dash_cooldown = 0.6 # Permanently upgrade dash cooldown!
			
			# ADICIONE ESTA LINHA:
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
			
	# Upgrade 2: Weighted Cane (Cost: 10 Francs)
	elif Global.weapon_scale == Vector2(1.0, 1.0):
		if Global.francs >= 10:
			Global.francs -= 10
			Global.weapon_scale = Vector2(1.4, 1.4) # Permanently increase weapon size by 40%!
			
			# Apply the upgrade immediately to the player standing in the shop!
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				players[0].attack_pivot.scale = Global.weapon_scale
				
			# ADICIONE ESTA LINHA:
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