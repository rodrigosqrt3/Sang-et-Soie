extends Area2D

@onready var color_rect: ColorRect = $ColorRect
@onready var prompt_label: Label = $PromptLabel

var elapsed_time: float = 0.0
var is_player_nearby: bool = false
const GLOW_SPEED: float = 12.0

func _ready() -> void:
	prompt_label.visible = false
	prompt_label.text = "[E] Pick up Key"
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if Global.current_quest == "grab_key":
		visible = true
		monitoring = true
		monitorable = true
	else:
		visible = false
		monitoring = false
		monitorable = false
		return

	elapsed_time += delta
	color_rect.color.a = 0.4 + (sin(elapsed_time * GLOW_SPEED) + 1.0) * 0.3
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
	Global.current_quest = "chapter_complete"
	Global.save_game()
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		var player: CharacterBody2D = players[0] as CharacterBody2D
		if player != null:
			var player_visual: ColorRect = player.get_node_or_null("ColorRect") as ColorRect
			if player_visual != null:
				player_visual.color = Color(0.8, 0.6, 0.0)
				await get_tree().create_timer(0.15).timeout
				player_visual.color = Color(0.14, 0.45, 0.23)
	queue_free()