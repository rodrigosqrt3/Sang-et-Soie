extends Area2D

@onready var prompt_label: Label = $PromptLabel
var is_player_nearby: bool = false

func _ready() -> void:
	prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if not is_player_nearby or not Input.is_action_just_pressed("interact"):
		return
	if Global.current_quest == Global.QUEST_ENTER_SEWERS:
		Global.begin_active_run()
		Global.save_game()
		Global.transition_to_scene.call_deferred("res://levels/underground/sewer_maintenance.tscn")
	else:
		prompt_label.text = "Locked sewer gate. I need the key."

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		if Global.current_quest == Global.QUEST_ENTER_SEWERS:
			prompt_label.text = "[E] Enter the maintenance tunnels"
		else:
			prompt_label.text = "Locked sewer gate"
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false