extends Area2D

@onready var color_rect: ColorRect = $ColorRect
@onready var prompt_label: Label = $PromptLabel

var elapsed_time: float = 0.0
var is_player_nearby: bool = false
const GLOW_SPEED: float = 12.0 # Frequency of the gold glow

func _ready() -> void:
	prompt_label.visible = false
	prompt_label.text = "[E] Pick up Key"
	
	# Connect physics signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	# CHANGE: ONLY show and activate the key if we are on the "grab_key" step!
	if Global.current_quest == "grab_key":
		visible = true
		monitoring = true
		monitorable = true
	else:
		visible = false
		monitoring = false
		monitorable = false
		return # Stop executing process if the key shouldn't exist yet
		
	# 2. Smoothly pulse opacity (glowing gold effect) using sine wave
	elapsed_time += delta
	color_rect.color.a = 0.4 + (sin(elapsed_time * GLOW_SPEED) + 1.0) / 2.0 * 0.6
	
	# 3. Handle collection input
	if is_player_nearby and Input.is_action_just_pressed("interact"):
		collect_key()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and visible:
		is_player_nearby = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false

func collect_key() -> void:
	print("Sewer key collected!")
	# Advance quest state to complete the chapter!
	Global.current_quest = "chapter_complete"
	
	# Trigger a beautiful gold flash effect directly on the player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		player.color_rect.color = Color(0.8, 0.6, 0.0) # Gold flash
		await get_tree().create_timer(0.15).timeout
		player.color_rect.color = player.EMERALD_GREEN
		
	queue_free() # Destroys the key node