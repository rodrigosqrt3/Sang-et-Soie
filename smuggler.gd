extends Area2D

@onready var speech_bubble: Label = $SpeechBubble
var is_player_nearby: bool = false

func _ready() -> void:
	speech_bubble.visible = false
	speech_bubble.text = ""
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if is_player_nearby and Input.is_action_just_pressed("interact"):
		if Global.current_quest == "talk_to_smuggler":
			start_quest_dialogue()
		elif Global.current_quest == "report_to_smuggler":
			finish_quest_dialogue()
		else:
			interact_with_shop() # Opens standard shop

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		update_shop_prompt()
		speech_bubble.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		speech_bubble.visible = false
		speech_bubble.text = ""

func update_shop_prompt() -> void:
	# Show different prompt options depending on what upgrades are already bought
	if Global.dash_cooldown == 1.0:
		speech_bubble.text = "Smuggler: [E] Buy Silk Cravat (5 Francs)\n(Reduces Dash Cooldown to 0.6s) | Wallet: " + str(Global.francs)
	elif Global.weapon_scale == Vector2(1.0, 1.0):
		speech_bubble.text = "Smuggler: [E] Buy Weighted Cane (10 Francs)\n(Increases Weapon Size by 40%) | Wallet: " + str(Global.francs)
	else:
		speech_bubble.text = "Smuggler: 'My inventory is empty, Étienne. Stay safe.'\nWallet: " + str(Global.francs)

func interact_with_shop() -> void:
	# Upgrade 1: Silk Cravat (Cost: 5 Francs)
	if Global.dash_cooldown == 1.0:
		if Global.francs >= 5:
			Global.francs -= 5
			Global.dash_cooldown = 0.6 # Permanently upgrade dash cooldown!
			speech_bubble.text = "Smuggler: 'Ah, pure silk. Elegant and fast, Étienne.'\n(Dash Cooldown permanently upgraded!)"
			await get_tree().create_timer(3.0).timeout
			if is_player_nearby: update_shop_prompt()
		else:
			speech_bubble.text = "Smuggler: 'You don't have 5 Francs, Étienne. Come back later.'\nWallet: " + str(Global.francs)
			
	# Upgrade 2: Weighted Cane (Cost: 10 Francs)
	elif Global.weapon_scale == Vector2(1.0, 1.0):
		if Global.francs >= 10:
			Global.francs -= 10
			Global.weapon_scale = Vector2(1.4, 1.4) # Permanently increase weapon size by 40%!
			
			# Apply the upgrade immediately to the player standing in the shop!
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0:
				players[0].attack_pivot.scale = Global.weapon_scale
				
			speech_bubble.text = "Smuggler: 'Lead-weighted enegreciated oak. Brutal.'\n(Weapon Size permanently upgraded by 40%!)"
			await get_tree().create_timer(3.0).timeout
			if is_player_nearby: update_shop_prompt()
		else:
			speech_bubble.text = "Smuggler: 'You don't have 10 Francs, Étienne. Come back later.'\nWallet: " + str(Global.francs)

func start_quest_dialogue() -> void:
	speech_bubble.text = "Smuggler: 'Étienne... Looking for Théodore? I have a lead,\nbut first clear the guards in the alley outside. Go!'"
	# Advance quest state so the exit door unlocks!
	Global.current_quest = "enter_streets"
	await get_tree().create_timer(4.0).timeout
	if is_player_nearby: update_shop_prompt()

func finish_quest_dialogue() -> void:
	Global.francs += 5 # Give 5 Francs reward!
	# Advance quest state to talk to Marguerite
	Global.current_quest = "talk_to_marguerite"
	speech_bubble.text = "Smuggler: 'Superb! Here are 5 Francs. For the lead...\ntalk to Marguerite. She knows about the old sewer gate.'"
	await get_tree().create_timer(4.0).timeout
	if is_player_nearby: update_shop_prompt()