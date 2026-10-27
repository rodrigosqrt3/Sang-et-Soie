extends Area2D

@export var event_id: String = ""
@export var speaker_name: String = "Paris"
@export_multiline var message_text: String = ""
@export var prompt_text: String = "Examine"
@export var required_quest: String = ""
@export var disabled_after_event: bool = true

var is_player_nearby: bool = false
var event_completed: bool = false

@onready var prompt_label: Label = $PromptLabel
@onready var visual: ColorRect = $Visual

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.visible = false
	refresh_availability()

func _process(_delta: float) -> void:
	refresh_availability()
	if is_player_nearby and is_available() and Input.is_action_just_pressed("interact"):
		activate_event()

func is_available() -> bool:
	if event_completed and disabled_after_event:
		return false
	return required_quest.is_empty() or Global.current_quest == required_quest

func refresh_availability() -> void:
	var available: bool = is_available()
	monitoring = available
	monitorable = available
	visual.modulate = Color.WHITE if available else Color(0.36, 0.36, 0.36, 0.45)
	if not available:
		prompt_label.visible = false

func activate_event() -> void:
	event_completed = true
	match event_id:
		"street_testimony":
			Global.saint_antoine_met_lucile = true
			Global.current_quest = Global.QUEST_SEARCH_WORKSHOP
		"workshop_proof":
			Global.saint_antoine_found_proof = true
			Global.current_quest = Global.QUEST_REACH_PRINTSHOP
		"protect_workers":
			Global.record_saint_antoine_choice("protect_workers")
		"pursue_theodore":
			Global.record_saint_antoine_choice("pursue_theodore")
		_:
			pass
	Global.save_game()
	show_message()
	refresh_availability()

func show_message() -> void:
	var hud_nodes: Array[Node] = get_tree().get_nodes_in_group("run_hud")
	if not hud_nodes.is_empty() and hud_nodes[0].has_method("show_message"):
		hud_nodes[0].call("show_message", speaker_name, message_text, 7.0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_available():
		is_player_nearby = true
		prompt_label.text = "[E] " + prompt_text
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false
