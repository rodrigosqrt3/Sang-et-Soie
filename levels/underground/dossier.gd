extends Area2D

@onready var prompt_label: Label = $PromptLabel
var is_player_nearby: bool = false

func _ready() -> void:
	prompt_label.visible = false
	prompt_label.text = "[E] Read the courier's ledger"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if is_player_nearby and Input.is_action_just_pressed("interact"):
		collect_dossier()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false

func collect_dossier() -> void:
	print("The courier's ledger reveals notes written by Théodore.")
	
	Global.theodore_knows_about_lists = true
	Global.current_quest = Global.QUEST_CHAPTER_ONE_COMPLETE
	Global.reset_active_run_state()
	Global.save_game()
	
	# Trigger a beautiful gold flash effect on the player to celebrate
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		var player: CharacterBody2D = players[0] as CharacterBody2D
		var player_visual: ColorRect = player.get_node_or_null("ColorRect") as ColorRect
		if player_visual != null:
			player_visual.color = Color(0.8, 0.6, 0.0)
			await get_tree().create_timer(0.2).timeout
			player_visual.color = Color(0.14, 0.45, 0.23)
		
	# Return to the Bal, where the chapter revelation is displayed.
	Global.transition_to_scene.call_deferred("res://levels/hub/bal_des_victimes.tscn")
	queue_free()