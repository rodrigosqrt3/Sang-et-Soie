extends Area2D

# The iron grate in the corner of the Bal: Madame's passage into the quarries.

@onready var prompt_label: Label = $PromptLabel
var is_player_nearby: bool = false

func _ready() -> void:
	prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if not is_player_nearby or not Input.is_action_just_pressed("interact") or not Dialogue.can_interact():
		return
	if Global.current_quest == Global.QUEST_ENTER_SEWERS:
		Global.begin_active_run()
		Global.save_game()
		Global.transition_to_scene.call_deferred("res://levels/underground/sewer_maintenance.tscn")
	else:
		Dialogue.bark("etienne", "Madame's grate. Locked, and the lock is older than the Republic.", 3.5)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		if Global.current_quest == Global.QUEST_ENTER_SEWERS:
			prompt_label.text = "[E] Descend into the quarries"
		else:
			prompt_label.text = "An iron grate, locked"
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false
