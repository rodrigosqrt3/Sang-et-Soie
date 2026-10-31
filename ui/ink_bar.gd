extends Control
class_name InkBar

# A thin bar drawn in ink: a hairline track and a filled stroke. Unlike
# ProgressBar it never grows to fit a font, so it can be a few pixels tall.

@export var max_value: float = 100.0
@export var value: float = 100.0:
	set(new_value):
		value = new_value
		queue_redraw()
@export var fill_color: Color = Color("E9E2D3")
@export var track_color: Color = Color(0.0, 0.0, 0.0, 0.55)
@export var edge_color: Color = Color("B8892E", 0.6)

func _draw() -> void:
	var rect: Rect2 = Rect2(Vector2.ZERO, size)
	draw_rect(rect, track_color)
	var ratio: float = clampf(value / maxf(0.001, max_value), 0.0, 1.0)
	if ratio > 0.0:
		draw_rect(Rect2(Vector2(1, 1), Vector2((size.x - 2) * ratio, size.y - 2)), fill_color)
	draw_rect(rect, edge_color, false, 1.0)
