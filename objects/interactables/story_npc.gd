extends Node2D
class_name StoryNPC

# A character Étienne can talk to. Builds its own paper figure, body, talk area
# and prompts; what it says comes from data/npc_topics.gd.

@export var npc_id: String = ""
@export var facing_left: bool = false
@export var interaction_radius: float = 56.0
@export var solid: bool = true

var figure: PaperFigure
var body: StaticBody2D
var area: Area2D
var prompt_label: Label
var new_marker: Label
var player_near: bool = false

func _ready() -> void:
	add_to_group("story_npcs")
	figure = PaperFigure.new()
	figure.look = CharacterData.get_look(npc_id)
	figure.seed_id = absi(npc_id.hash()) % 997
	figure.facing_left = facing_left
	figure.lean = float(CharacterData.get_profile(npc_id).get("lean", 0.0))
	# Characters keep breathing while a conversation pauses the world.
	figure.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(figure)

	if solid:
		body = StaticBody2D.new()
		var body_shape: CollisionShape2D = CollisionShape2D.new()
		var rectangle: RectangleShape2D = RectangleShape2D.new()
		rectangle.size = Vector2(26, 16)
		body_shape.shape = rectangle
		body_shape.position = Vector2(0, 10)
		body.add_child(body_shape)
		add_child(body)

	area = Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	var area_shape: CollisionShape2D = CollisionShape2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = interaction_radius
	area_shape.shape = circle
	area.add_child(area_shape)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	add_child(area)

	prompt_label = make_label(Vector2(-110, -78), Vector2(220, 20), 13, Style.BONE)
	prompt_label.visible = false
	new_marker = make_label(Vector2(-10, -64), Vector2(20, 24), 22, Style.CANDLE)
	new_marker.text = "!"
	add_child(prompt_label)
	add_child(new_marker)

	Dialogue.conversation_finished.connect(func(_id: String) -> void: refresh())
	refresh()

func make_label(at: Vector2, label_size: Vector2, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.position = at
	label.size = label_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.label_settings = Style.caps_settings(font_size, color)
	label.label_settings.shadow_color = Color(0, 0, 0, 0.8)
	label.label_settings.shadow_offset = Vector2(1, 1)
	label.z_index = 20
	return label

func refresh() -> void:
	var present: bool = NPCTopics.is_present(npc_id)
	visible = present
	process_mode = Node.PROCESS_MODE_INHERIT if present else Node.PROCESS_MODE_DISABLED
	if body != null:
		for child in body.get_children():
			(child as CollisionShape2D).set_deferred("disabled", not present)
	if not present:
		player_near = false

func _process(_delta: float) -> void:
	new_marker.visible = NPCTopics.has_new_topic(npc_id)
	new_marker.position.y = -64.0 + sin(Time.get_ticks_msec() * 0.005) * 2.0
	prompt_label.visible = player_near and not Dialogue.is_active()
	if player_near and Input.is_action_just_pressed("interact") and Dialogue.can_interact():
		talk()

func talk() -> void:
	var topic: Dictionary = NPCTopics.pick(npc_id)
	if topic.is_empty():
		return
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		figure.face_toward((players[0] as Node2D).global_position - global_position)
	var start: String = str(topic.get("start", ""))
	if start.begins_with("action:"):
		Dialogue.run_action(start.substr(7), [])
	else:
		Dialogue.start(start)

func _on_body_entered(entered: Node2D) -> void:
	if entered.is_in_group("player"):
		player_near = true
		prompt_label.text = "[E]  " + CharacterData.get_display_name(npc_id)

func _on_body_exited(exited: Node2D) -> void:
	if exited.is_in_group("player"):
		player_near = false
