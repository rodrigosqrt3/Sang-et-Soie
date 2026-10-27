extends Area2D

@export var shortcut_id: String = ""
@export var cipher_text: String = "II"
@export var reveal_prompt: String = "[E] Decipher the concealed mason's mark"
@export var discovered_text: String = "PASSAGE MAPPED"

var nearby_player: Node = null
var discovered: bool = false

@onready var visual: Node2D = $Visual
@onready var cipher_label: Label = $Visual/Cipher
@onready var prompt_label: Label = $PromptLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	discovered = not shortcut_id.is_empty() and Global.is_shortcut_unlocked(shortcut_id)
	cipher_label.text = cipher_text
	prompt_label.visible = false
	refresh_visual()

func _process(_delta: float) -> void:
	var monocle_active: bool = is_monocle_active()
	visual.visible = discovered or monocle_active
	if discovered:
		visual.modulate = Color(0.58, 0.82, 0.76, 0.48)
	else:
		visual.modulate = Color(0.68, 0.92, 1.0, 0.92)

	if nearby_player == null:
		prompt_label.visible = false
		return

	prompt_label.visible = discovered or monocle_active
	prompt_label.text = discovered_text if discovered else reveal_prompt
	if not discovered and monocle_active and Input.is_action_just_pressed("interact"):
		discover_mark()

func is_monocle_active() -> bool:
	if nearby_player == null:
		return false
	return bool(nearby_player.get("is_using_monocle"))

func discover_mark() -> void:
	if discovered or shortcut_id.is_empty():
		return
	discovered = true
	Global.unlock_shortcut(shortcut_id)
	get_tree().call_group("district_passages", "refresh_state")
	var level: Node = get_parent()
	if level.has_method("register_secret_discovery"):
		level.call("register_secret_discovery", shortcut_id)
	refresh_visual()

func refresh_visual() -> void:
	visual.visible = discovered
	prompt_label.text = discovered_text if discovered else reveal_prompt

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		nearby_player = body

func _on_body_exited(body: Node2D) -> void:
	if body == nearby_player:
		nearby_player = null
		prompt_label.visible = false