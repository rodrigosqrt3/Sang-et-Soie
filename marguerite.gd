extends Area2D

var is_player_nearby: bool = false

# Reference to the main hub controller
@onready var hub: Node2D = get_parent()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if is_player_nearby and Input.is_action_just_pressed("interact"):
		talk()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		hub.show_dialogue("Marguerite Colbert", "[E] Talk to Marguerite")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		hub.hide_dialogue()

func talk() -> void:
	if Global.current_quest == "talk_to_marguerite":
		hub.show_dialogue(
			"Marguerite Colbert", 
			"Madame disliked locked doors. During the Terror, her passage carried nobles, servants, printers. Anyone who needed to vanish. I hid the key beneath the loose boards in the lower corner. She would complain about the dust."
		)
		Global.current_quest = "grab_key"
		Global.save_game()
	elif Global.current_quest == "grab_key":
		hub.show_dialogue("Marguerite Colbert", "The key is hidden under the floorboards in the bottom corner, Étienne.")
	else:
		hub.show_dialogue("Marguerite Colbert", "Madame prefers the Burgundy, Étienne...")