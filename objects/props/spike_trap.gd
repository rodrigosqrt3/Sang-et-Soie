extends Area2D

const IDLE_COLOR: Color = Color(0.2, 0.29, 0.37)
const WARNING_COLOR: Color = Color(0.9, 0.3, 0.23)
const ACTIVE_COLOR: Color = Color(0.92, 0.94, 0.95)
const REGARD_COLOR: Color = Color(0.95, 0.76, 0.13)

var is_triggered: bool = false
var overlapping_bodies: Array[Node2D] = []

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.color = IDLE_COLOR
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") and not body.is_in_group("enemies"):
		return
	if not overlapping_bodies.has(body):
		overlapping_bodies.append(body)
	if not is_triggered:
		trigger_trap()

func _on_body_exited(body: Node2D) -> void:
	overlapping_bodies.erase(body)

func trigger_trap() -> void:
	is_triggered = true
	color_rect.color = WARNING_COLOR
	await get_tree().create_timer(0.5).timeout
	if not is_inside_tree():
		return

	color_rect.color = ACTIVE_COLOR
	for body: Node2D in overlapping_bodies.duplicate():
		if is_instance_valid(body) and body.has_method("take_damage"):
			body.call("take_damage", 1)

	await get_tree().create_timer(0.3).timeout
	if not is_inside_tree():
		return
	color_rect.color = IDLE_COLOR
	await get_tree().create_timer(1.5).timeout
	if not is_inside_tree():
		return

	is_triggered = false
	if not overlapping_bodies.is_empty():
		trigger_trap()

func _process(delta: float) -> void:
	if is_triggered:
		return
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		color_rect.color = color_rect.color.lerp(IDLE_COLOR, delta * 8.0)
		return
	var player: CharacterBody2D = players[0] as CharacterBody2D
	var target_color: Color = REGARD_COLOR if player != null and bool(player.get("is_using_monocle")) else IDLE_COLOR
	color_rect.color = color_rect.color.lerp(target_color, delta * 8.0)