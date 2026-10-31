extends Area2D

# An iron plate that springs half a second after something steps on it, and
# hurts guards as readily as Étienne. Le Regard shows it for what it is.

const WARNING_TINT: Color = Color(0.9, 0.3, 0.23)
const REGARD_TINT: Color = Color(0.95, 0.76, 0.13)

var is_triggered: bool = false
var overlapping_bodies: Array[Node2D] = []
var art: PropArt

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.visible = false
	art = PropArt.attach(self, "trap")
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
	art.state = "warning"
	await get_tree().create_timer(0.5).timeout
	if not is_inside_tree():
		return

	art.state = "active"
	for body: Node2D in overlapping_bodies.duplicate():
		if not is_instance_valid(body) or not body.has_method("take_damage"):
			continue
		if body.is_in_group("enemies"):
			body.call("take_damage", 1, false)
		else:
			body.call("take_damage", 1)

	await get_tree().create_timer(0.3).timeout
	if not is_inside_tree():
		return
	art.state = ""
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
	var regard: bool = not players.is_empty() and bool(players[0].get("is_using_monocle"))
	art.tint = art.tint.lerp(REGARD_TINT if regard else Color.WHITE, minf(1.0, delta * 8.0))
