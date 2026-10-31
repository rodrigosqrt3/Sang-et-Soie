extends Area2D

var is_player_nearby: bool = false

@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.visible = false

func _process(_delta: float) -> void:
	if not is_player_nearby or not Input.is_action_just_pressed("interact"):
		return
	if Global.current_quest != Global.QUEST_ESCAPE_SAINT_ANTOINE:
		prompt_label.text = "The raid blocks every quiet exit. A decision remains inside."
		return
	Global.current_quest = Global.QUEST_CHAPTER_TWO_COMPLETE
	Global.complete_excursion()
	Global.transition_to_scene.call_deferred("res://levels/hub/bal_des_victimes.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		prompt_label.text = "[E] Escape through the dyer's courtyard"
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false