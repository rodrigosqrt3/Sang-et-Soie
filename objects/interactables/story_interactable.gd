extends Area2D

# A story beat inside an excursion: a witness, a clue, a decision. If a
# conversation with the same id as event_id exists, it plays as dialogue;
# otherwise message_text is shown as a bark.

@export var event_id: String = ""
@export var speaker_name: String = "Paris"
@export_multiline var message_text: String = ""
@export var prompt_text: String = "Examine"
@export var required_quest: String = ""
@export var disabled_after_event: bool = true
# Optional: draw this character (data/characters.gd) instead of a plain marker.
@export var character_id: String = ""

var is_player_nearby: bool = false
var event_completed: bool = false
var figure: PaperFigure

@onready var prompt_label: Label = $PromptLabel
@onready var visual: ColorRect = $Visual

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.visible = false
	if not character_id.is_empty():
		visual.visible = false
		figure = PaperFigure.new()
		figure.look = CharacterData.get_look(character_id)
		figure.seed_id = absi(character_id.hash()) % 997
		add_child(figure)
	else:
		build_clue_marker()
	refresh_availability()

# Clues are marked by a small paper tag with an ink cross, not a coloured box.
func build_clue_marker() -> void:
	visual.color = Color(0, 0, 0, 0)
	var tag: Polygon2D = Polygon2D.new()
	tag.polygon = PackedVector2Array([Vector2(-10, -7), Vector2(11, -8), Vector2(10, 8), Vector2(-11, 7)])
	tag.color = Style.BONE
	add_child(tag)
	var cross: Line2D = Line2D.new()
	cross.points = PackedVector2Array([Vector2(-5, -4), Vector2(5, 4)])
	cross.width = 1.6
	cross.default_color = Style.BURGUNDY
	tag.add_child(cross)
	var cross_b: Line2D = cross.duplicate()
	cross_b.points = PackedVector2Array([Vector2(5, -4), Vector2(-5, 4)])
	tag.add_child(cross_b)

func _process(_delta: float) -> void:
	refresh_availability()
	if is_player_nearby and is_available() and Input.is_action_just_pressed("interact") and Dialogue.can_interact():
		activate_event()

func is_available() -> bool:
	if event_completed and disabled_after_event:
		return false
	return required_quest.is_empty() or Global.current_quest == required_quest

func refresh_availability() -> void:
	var available: bool = is_available()
	monitoring = available
	monitorable = available
	var tint: Color = Color.WHITE if available else Color(0.45, 0.45, 0.45, 0.55)
	visual.modulate = tint
	if figure != null:
		figure.modulate = tint
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
	if DialogueLibrary.has_conversation(event_id):
		Dialogue.start(event_id)
	else:
		Dialogue.bark(speaker_name, message_text, 7.0)
	refresh_availability()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_available():
		is_player_nearby = true
		prompt_label.text = "[E] " + prompt_text
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false
