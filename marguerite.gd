extends Area2D

@onready var speech_bubble: Label = $SpeechBubble

# State variable to track if the player is within conversational range
var is_player_nearby: bool = false

func _ready() -> void:
	# Hide the speech bubble at the start
	speech_bubble.visible = false
	speech_bubble.text = ""
	
	# Connect physics signals to detect the player entering/exiting Marguerite's social space
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# If the player is close and presses the interact key (E)
	if is_player_nearby and Input.is_action_just_pressed("interact"):
		talk()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		# Show a prompt to interact instead of speaking automatically
		speech_bubble.text = "[E] Talk to Marguerite"
		speech_bubble.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		speech_bubble.visible = false
		speech_bubble.text = ""

func talk() -> void:
	# Dialogue branches depending on the current active quest
	if Global.current_quest == "talk_to_marguerite":
		speech_bubble.text = "Marguerite: 'Étienne! You returned... Is Paris still bleeding?\nThe sewer key... I hid it under the floorboards.'"
	else:
		speech_bubble.text = "Madame prefers the Burgundy, Étienne..."
		
	await get_tree().create_timer(3.0).timeout
	
	if is_player_nearby:
		speech_bubble.text = "[E] Talk to Marguerite"
	else:
		speech_bubble.visible = false
		speech_bubble.text = ""
