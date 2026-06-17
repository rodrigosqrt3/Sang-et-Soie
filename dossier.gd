extends Area2D

@onready var prompt_label: Label = $PromptLabel
var is_player_nearby: bool = false

func _ready() -> void:
	prompt_label.visible = false
	prompt_label.text = "[E] Grab Dossier"
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
	print("Théodore's Dossier secured!")
	
	# Complete Chapter I!
	Global.current_quest = "campaign_complete"
	
	# Trigger a beautiful gold flash effect on the player to celebrate
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		player.color_rect.color = Color(0.8, 0.6, 0.0) # Gold flash
		await get_tree().create_timer(0.2).timeout
		player.color_rect.color = player.EMERALD_GREEN
		
	# Change scene back to our safe Hub to see the final objective!
	get_tree().change_scene_to_file.call_deferred("res://bal_des_victimes.tscn")
	queue_free()