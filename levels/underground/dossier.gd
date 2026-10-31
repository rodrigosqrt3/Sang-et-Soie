extends Area2D

# The copyist's ledger, dropped where Mâchefer fell. Reading it ends Act I.

@onready var prompt_label: Label = $PromptLabel
var is_player_nearby: bool = false
var collected: bool = false

func _ready() -> void:
	prompt_label.visible = false
	prompt_label.text = "[E] Read the copyist's ledger"
	$ColorRect.visible = false
	PropArt.attach(self, "ledger")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if is_player_nearby and Input.is_action_just_pressed("interact") and Dialogue.can_interact():
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
	if collected:
		return
	collected = true
	prompt_label.visible = false
	for player in get_tree().get_nodes_in_group("player"):
		if player.has_method("flash_gold"):
			player.call("flash_gold")

	Dialogue.start("ledger_found")
	await Dialogue.conversation_finished

	Global.theodore_knows_about_lists = true
	Global.current_quest = Global.QUEST_CHAPTER_ONE_COMPLETE
	Global.complete_excursion()
	# Return to the Bal, where the chapter revelation is displayed.
	Global.transition_to_scene.call_deferred("res://levels/hub/bal_des_victimes.tscn")
	queue_free()
