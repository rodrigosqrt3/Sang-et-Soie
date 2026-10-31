extends Control
class_name RibbonMeter

# Health as red ribbon bows, the Bal's emblem: a full bow per life, an ink
# outline for each one lost.

@export var maximum: int = 3:
	set(value):
		maximum = value
		queue_redraw()
@export var value: int = 3:
	set(new_value):
		value = new_value
		queue_redraw()
@export var filled_color: Color = Color("B3202C")

func _draw() -> void:
	for i in range(maximum):
		var c: Vector2 = Vector2(14 + i * 30, size.y * 0.5)
		var left: PackedVector2Array = PackedVector2Array([c, c + Vector2(-11, -7), c + Vector2(-11, 7)])
		var right: PackedVector2Array = PackedVector2Array([c, c + Vector2(11, -7), c + Vector2(11, 7)])
		var tail_l: PackedVector2Array = PackedVector2Array([c, c + Vector2(-5, 12), c + Vector2(-1, 12)])
		var tail_r: PackedVector2Array = PackedVector2Array([c, c + Vector2(5, 12), c + Vector2(1, 12)])
		var alive: bool = i < value
		for shape in [left, right, tail_l, tail_r]:
			if alive:
				draw_colored_polygon(shape, filled_color)
			var outline: PackedVector2Array = (shape as PackedVector2Array).duplicate()
			outline.append(shape[0])
			draw_polyline(outline, Color("E9E2D3") if not alive else filled_color.darkened(0.5), 1.2)
		draw_circle(c, 2.6, filled_color.darkened(0.3) if alive else Color("E9E2D3", 0.4))
