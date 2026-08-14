extends Area2D

@export_file("*.tscn") var destination_scene: String = ""
@export var destination_spawn_id: String = "default"
@export var shortcut_id: String = ""
@export var requires_unlocked_shortcut: bool = false
@export var unlock_shortcut_on_use: bool = false
@export var prompt_text: String = "Use passage"
@export var locked_text: String = "Barred from the other side"
@export var reveal_mark_with_monocle: bool = false
@export var cipher_mark_text: String = "V"

var is_player_nearby: bool = false
var transition_in_progress: bool = false

@onready var prompt_label: Label = $PromptLabel
@onready var gate_visual: ColorRect = $GateVisual
@onready var gate_collision: CollisionShape2D = $GateBody/CollisionShape2D
@onready var cipher_mark: Label = $CipherMark

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.visible = false
	cipher_mark.text = cipher_mark_text
	cipher_mark.visible = false
	refresh_state()

func _process(_delta: float) -> void:
	update_cipher_mark()
	if is_player_nearby and Input.is_action_just_pressed("interact"):
		use_passage()

func update_cipher_mark() -> void:
	if not reveal_mark_with_monocle:
		cipher_mark.visible = false
		return
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		cipher_mark.visible = false
		return
	var player: Node = players[0]
	cipher_mark.visible = bool(player.get("is_using_monocle"))

func is_locked() -> bool:
	return requires_unlocked_shortcut and not Global.is_shortcut_unlocked(shortcut_id)

func refresh_state() -> void:
	var locked: bool = is_locked()
	gate_collision.set_deferred("disabled", not locked)
	if locked:
		gate_visual.color = Color(0.22, 0.18, 0.16, 1.0)
	else:
		gate_visual.color = Color(0.2, 0.42, 0.34, 1.0)
	refresh_prompt()

func refresh_prompt() -> void:
	if not is_player_nearby:
		return
	if is_locked():
		prompt_label.text = "[E] " + locked_text
	else:
		prompt_label.text = "[E] " + prompt_text

func use_passage() -> void:
	if transition_in_progress:
		return
	if is_locked():
		refresh_prompt()
		return

	transition_in_progress = true
	if unlock_shortcut_on_use and not shortcut_id.is_empty():
		Global.unlock_shortcut(shortcut_id)
	refresh_state()
	Global.travel_to_scene(destination_scene, destination_spawn_id)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		prompt_label.visible = true
		refresh_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false