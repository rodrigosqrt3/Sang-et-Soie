@tool
extends Control
class_name PaperCard

# A sheet of paper cut by hand: drop shadow, slightly irregular edges, a faint
# deckle along the border and a few fibres. Used for dialogue, barks and HUD.

@export var paper_color: Color = Color("E9E2D3"):
	set(value):
		paper_color = value
		queue_redraw()
@export var edge_color: Color = Color("2A2320"):
	set(value):
		edge_color = value
		queue_redraw()
@export var jitter: float = 1.6
@export var shadow_offset: Vector2 = Vector2(4, 6)
@export var shadow_alpha: float = 0.45
@export var fibre_count: int = 18
@export var seed_id: int = 3

func _ready() -> void:
	resized.connect(queue_redraw)

func _draw() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_id * 4513
	var outline: PackedVector2Array = _cut_outline(Rect2(Vector2.ZERO, size), rng)

	var shadow: PackedVector2Array = PackedVector2Array()
	for point in outline:
		shadow.append(point + shadow_offset)
	draw_colored_polygon(shadow, Color(0, 0, 0, shadow_alpha))
	draw_colored_polygon(outline, paper_color)

	# Fibres: short, faint strokes that make flat colour read as paper.
	for i in range(fibre_count):
		var start: Vector2 = Vector2(rng.randf_range(8, size.x - 8), rng.randf_range(6, size.y - 6))
		var direction: Vector2 = Vector2.RIGHT.rotated(rng.randf_range(-0.5, 0.5))
		draw_line(start, start + direction * rng.randf_range(6, 22), Color(paper_color.darkened(0.12), 0.5), 1.0)

	var closed: PackedVector2Array = outline.duplicate()
	closed.append(outline[0])
	draw_polyline(closed, Color(edge_color, 0.85), 1.4)
	# Inner deckle: a second, lighter line just inside the cut.
	var inner: PackedVector2Array = _cut_outline(Rect2(Vector2(5, 5), size - Vector2(10, 10)), rng)
	inner.append(inner[0])
	draw_polyline(inner, Color(edge_color, 0.18), 1.0)

func _cut_outline(rect: Rect2, rng: RandomNumberGenerator) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	var corners: Array[Vector2] = [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
	for i in range(4):
		var from: Vector2 = corners[i]
		var to: Vector2 = corners[(i + 1) % 4]
		var steps: int = maxi(2, int(from.distance_to(to) / 26.0))
		for step in range(steps):
			var point: Vector2 = from.lerp(to, float(step) / steps)
			points.append(point + Vector2(rng.randf_range(-jitter, jitter), rng.randf_range(-jitter, jitter)))
	return points
