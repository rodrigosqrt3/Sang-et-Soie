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
		# Showing the expanded narrative on the beautiful bottom HUD dialogue!
		hub.show_dialogue(
			"Marguerite Colbert", 
			"Étienne! You returned... Is Paris still bleeding? The sewer key... My late Madame used it to smuggle nobles out during the Terror. I hid it under the floorboards near the bottom corner."
		)
		Global.current_quest = "grab_key"
	elif Global.current_quest == "grab_key":
		hub.show_dialogue("Marguerite Colbert", "The key is hidden under the floorboards in the bottom corner, Étienne.")
	else:
		hub.show_dialogue("Marguerite Colbert", "Madame prefers the Burgundy, Étienne...")