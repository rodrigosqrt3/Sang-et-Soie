extends Area2D

@onready var prompt_label: Label = $PromptLabel
var is_player_nearby: bool = false

func _ready() -> void:
	prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# If player is near and presses E
	if is_player_nearby and Input.is_action_just_pressed("interact"):
		if Global.current_quest == "chapter_complete":
			print("Entering the sewers...")
			# Defer changing scene to our new sewers level safely
			get_tree().change_scene_to_file.call_deferred("res://sewers.tscn")
		else:
			prompt_label.text = "Locked sewer gate. I need the key."

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		if Global.current_quest == "chapter_complete":
			prompt_label.text = "[E] Enter the Sewers"
		else:
			prompt_label.text = "Locked sewer gate"
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false