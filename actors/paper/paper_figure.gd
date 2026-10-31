@tool
extends Node2D
class_name PaperFigure

# A character drawn as a hand-cut paper puppet. Every figure in the game is a
# "look" dictionary rendered by code: the coat, collar, hat and hair are layered
# polygons with a drop shadow, an ink outline and slightly irregular edges.
#
# Origin = the character's collision centre. Feet rest at y = +18.

const OUTLINE_DARKEN: float = 0.55
const SHADOW_COLOR: Color = Color(0.0, 0.0, 0.0, 0.26)
const SHADOW_OFFSET: Vector2 = Vector2(1.6, 2.2)

const DEFAULT_LOOK: Dictionary = {
	"skin": Color(0.93, 0.84, 0.76),
	"hair": Color(0.36, 0.24, 0.16),
	"hair_style": "curls",
	"coat": Color(0.12, 0.42, 0.35),
	"coat_style": "tails",
	"trim": Color(0.08, 0.08, 0.09),
	"fur": false,
	"legs": Color(0.1, 0.09, 0.1),
	"gaiters": null,
	"shoes": Color(0.05, 0.04, 0.04),
	"collar": Color(0.91, 0.89, 0.83),
	"collar_height": 0.7,
	"ribbon": null,
	"hat": "none",
	"hat_color": Color(0.08, 0.07, 0.08),
	"cockade": null,
	"lips": null,
	"accessory": "none",
	"accessory_color": Color(0.2, 0.13, 0.08),
	"build": 1.0,
	"height": 1.0,
}

@export var look: Dictionary = {}:
	set(value):
		look = value
		_resolved = {}
		queue_redraw()
@export var seed_id: int = 1:
	set(value):
		seed_id = value
		queue_redraw()
@export var lean: float = 0.0:
	set(value):
		lean = value
		_sway = value
		queue_redraw()

var flash_color: Color = Color.WHITE
var flash_amount: float = 0.0
var moving_ratio: float = 0.0
var facing_left: bool = false

var _resolved: Dictionary = {}
var _time: float = 0.0
var _bob: float = 0.0
var _sway: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_time = float(seed_id) * 0.37

func _process(delta: float) -> void:
	_time += delta
	# Walking: a paper puppet bobs and rocks on its feet instead of moving limbs.
	if moving_ratio > 0.05:
		_bob = -absf(sin(_time * 11.0)) * 2.2 * moving_ratio
		_sway = lean + sin(_time * 11.0) * 0.06 * moving_ratio
	else:
		_bob = sin(_time * 1.6) * 0.5
		_sway = lean + sin(_time * 1.1) * 0.015
	scale.x = -absf(scale.x) if facing_left else absf(scale.x)
	queue_redraw()

func set_moving(velocity: Vector2, max_speed: float) -> void:
	moving_ratio = clampf(velocity.length() / maxf(1.0, max_speed), 0.0, 1.0)
	if absf(velocity.x) > 4.0:
		facing_left = velocity.x < 0.0

func face_toward(direction: Vector2) -> void:
	if absf(direction.x) > 0.05:
		facing_left = direction.x < 0.0

func set_flash(color: Color, amount: float) -> void:
	flash_color = color
	flash_amount = clampf(amount, 0.0, 1.0)
	queue_redraw()

func flash(color: Color, duration: float = 0.1) -> void:
	set_flash(color, 0.85)
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(self):
		set_flash(Color.WHITE, 0.0)

func set_look_value(key: String, value: Variant) -> void:
	var updated: Dictionary = look.duplicate()
	updated[key] = value
	look = updated

func get_look() -> Dictionary:
	if _resolved.is_empty():
		_resolved = DEFAULT_LOOK.duplicate()
		for key in look.keys():
			_resolved[key] = look[key]
	return _resolved

# =========================================================
# DRAWING
# =========================================================
func _draw() -> void:
	var l: Dictionary = get_look()
	_rng.seed = seed_id * 7919
	var w: float = float(l["build"])
	var h: float = float(l["height"])

	# Ground shadow is not part of the paper: it never flashes, bobs or rocks.
	_draw_ellipse(Vector2(0, 18), Vector2(15.0 * w, 4.5), Color(0, 0, 0, 0.3))

	# The puppet pivots on its feet (y = 18), so a lean tilts it like card
	# pinned at the base rather than spinning it around its belly.
	var body: Transform2D = Transform2D(_sway, Vector2(w, h), 0.0, Vector2.ZERO)
	body.origin = Vector2(0, 18 + _bob) - body.basis_xform(Vector2(0, 18))
	draw_set_transform_matrix(body)

	var coat_style: String = str(l["coat_style"])
	var coat: Color = _c(l["coat"])
	var trim: Color = _c(l["trim"])

	# Back layers: coat tails and long skirts sit behind the legs.
	if coat_style == "tails":
		_paper(PackedVector2Array([Vector2(-10, -2), Vector2(-14, 15), Vector2(-7, 13), Vector2(-3, 3)]), coat.darkened(0.12))
		_paper(PackedVector2Array([Vector2(10, -2), Vector2(14, 15), Vector2(7, 13), Vector2(3, 3)]), coat.darkened(0.12))

	_draw_legs(l, coat_style)
	_draw_coat(l, coat_style, coat, trim)
	_draw_arms(l, coat_style, coat)
	_draw_accessory(l)
	_draw_collar(l)
	_draw_head(l)
	_draw_hat(l)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_legs(l: Dictionary, coat_style: String) -> void:
	if coat_style == "dress":
		return
	var legs: Color = _c(l["legs"])
	var shoes: Color = _c(l["shoes"])
	for side in [-1.0, 1.0]:
		var x: float = 3.8 * side
		_paper(PackedVector2Array([Vector2(x - 2.6, 2), Vector2(x + 2.6, 2), Vector2(x + 2.2, 17), Vector2(x - 2.2, 17)]), legs, false)
		if l["gaiters"] != null:
			_paper(PackedVector2Array([Vector2(x - 2.7, 11), Vector2(x + 2.7, 11), Vector2(x + 2.4, 17), Vector2(x - 2.4, 17)]), _c(l["gaiters"]), false)
		_draw_ellipse(Vector2(x + 0.8 * side, 17.6), Vector2(3.4, 1.6), shoes)

func _draw_coat(l: Dictionary, coat_style: String, coat: Color, trim: Color) -> void:
	match coat_style:
		"dress":
			# High Directoire waist, the skirt falling straight to the floor.
			_paper(PackedVector2Array([Vector2(-7, -9), Vector2(7, -9), Vector2(13, 18), Vector2(0, 19), Vector2(-13, 18)]), coat)
			_paper(PackedVector2Array([Vector2(-8, -18), Vector2(8, -18), Vector2(7, -9), Vector2(-7, -9)]), coat.lightened(0.08))
			_line(Vector2(-7, -9), Vector2(7, -9), _c(l["trim"]), 1.4)
		"long", "trench":
			var flare: float = 15.0 if coat_style == "trench" else 13.0
			_paper(PackedVector2Array([Vector2(-12, -18), Vector2(12, -18), Vector2(flare, 12), Vector2(-flare, 12)]), coat)
			_line(Vector2(0, -14), Vector2(1, 12), coat.darkened(0.35), 1.0)
			_paper(PackedVector2Array([Vector2(-5, -18), Vector2(0, -10), Vector2(-7, -4)]), trim, false)
			_paper(PackedVector2Array([Vector2(5, -18), Vector2(0, -10), Vector2(7, -4)]), trim, false)
		"smock":
			_paper(PackedVector2Array([Vector2(-11, -17), Vector2(11, -17), Vector2(12, 6), Vector2(-12, 6)]), coat)
			_line(Vector2(-11, 2), Vector2(11, 2), coat.darkened(0.3), 1.2)
		_:
			# Incroyable tailcoat: huge shoulders, cut away at the waist.
			_paper(PackedVector2Array([Vector2(-13, -18), Vector2(13, -18), Vector2(10, 2), Vector2(4, 5), Vector2(-4, 5), Vector2(-10, 2)]), coat)
			_paper(PackedVector2Array([Vector2(-6, -18), Vector2(0, -8), Vector2(-9, -3)]), trim, false)
			_paper(PackedVector2Array([Vector2(6, -18), Vector2(0, -8), Vector2(9, -3)]), trim, false)
	if bool(l["fur"]):
		for i in range(7):
			var x: float = -12.0 + i * 4.0
			_draw_ellipse(Vector2(x, -17.5 + _rng.randf_range(-0.6, 0.6)), Vector2(2.8, 2.4), _c(Color(0.45, 0.3, 0.18)))

func _draw_arms(l: Dictionary, coat_style: String, coat: Color) -> void:
	var sleeve: Color = coat.darkened(0.08)
	var top: float = -9.0 if coat_style == "dress" else -16.0
	if coat_style == "dress":
		sleeve = _c(l["skin"])
	for side in [-1.0, 1.0]:
		var s: float = side
		_paper(PackedVector2Array([Vector2(11 * s, top), Vector2(15 * s, top + 2), Vector2(16 * s, 0), Vector2(12.5 * s, 0.5)]), sleeve, false)
		_draw_circle_paper(Vector2(14.3 * s, 1.6), 2.2, _c(l["skin"]))

func _draw_accessory(l: Dictionary) -> void:
	var accessory: String = str(l["accessory"])
	var color: Color = _c(l["accessory_color"])
	match accessory:
		"cane":
			_line(Vector2(15, 1), Vector2(18, 18), color, 1.6)
			_draw_circle_paper(Vector2(15, 0.5), 1.7, _c(Color(0.82, 0.66, 0.3)))
		"ledger":
			_paper(PackedVector2Array([Vector2(-17, -4), Vector2(-11, -5), Vector2(-10, 4), Vector2(-16, 5)]), color)
		"musket":
			_line(Vector2(13, 6), Vector2(19, -24), _c(Color(0.32, 0.2, 0.1)), 2.0)
			_line(Vector2(17.5, -18), Vector2(19.5, -27), _c(Color(0.7, 0.72, 0.74)), 1.0)
		"sabre":
			_line(Vector2(-13, -2), Vector2(-17, 15), _c(Color(0.78, 0.8, 0.82)), 1.4)
		"bag":
			_paper(PackedVector2Array([Vector2(-18, 0), Vector2(-11, -2), Vector2(-10, 9), Vector2(-18, 10)]), color)
		"bottle":
			_paper(PackedVector2Array([Vector2(14, -3), Vector2(16, -3), Vector2(17, 4), Vector2(13, 4)]), _c(Color(0.3, 0.42, 0.22)))

func _draw_collar(l: Dictionary) -> void:
	var height_ratio: float = float(l["collar_height"])
	if height_ratio <= 0.0:
		return
	# The armoured neck: a white stock that can climb to the ears.
	var collar: Color = _c(l["collar"])
	var top: float = -21.0 - 5.0 * height_ratio
	_paper(PackedVector2Array([Vector2(-6.5, -17), Vector2(6.5, -17), Vector2(5.5, top), Vector2(0, top + 1.5), Vector2(-5.5, top)]), collar)
	if l["ribbon"] != null:
		var ribbon: Color = _c(l["ribbon"])
		_paper(PackedVector2Array([Vector2(0, -18), Vector2(-4.5, -20.5), Vector2(-4, -15.5)]), ribbon, false)
		_paper(PackedVector2Array([Vector2(0, -18), Vector2(4.5, -20.5), Vector2(4, -15.5)]), ribbon, false)
		_paper(PackedVector2Array([Vector2(-0.5, -18), Vector2(-2, -12), Vector2(0.6, -13)]), ribbon.darkened(0.2), false)

func _draw_head(l: Dictionary) -> void:
	var skin: Color = _c(l["skin"])
	var hair: Color = _c(l["hair"])
	var style: String = str(l["hair_style"])
	var head_center: Vector2 = Vector2(0, -29)

	if style == "frizz":
		# Merveilleuse volume, as if blown by something.
		var blob: PackedVector2Array = PackedVector2Array()
		for i in range(18):
			var a: float = TAU * i / 18.0
			var r: float = 12.5 + _rng.randf_range(-2.2, 2.6)
			blob.append(head_center + Vector2(cos(a) * r, sin(a) * r * 0.92 - 1.5))
		_paper(blob, hair)
	elif style == "long":
		# Loose hair falling behind the head to the shoulders, unpowdered.
		_paper(PackedVector2Array([Vector2(-6, -36), Vector2(6, -36), Vector2(9, -30), Vector2(10, -19), Vector2(6, -16),
			Vector2(3, -21), Vector2(-3, -21), Vector2(-6, -16), Vector2(-10, -19), Vector2(-9, -30)]), hair)

	_draw_circle_paper(head_center, 7.2, skin)

	match style:
		"curls":
			# Incroyable "dog's ears": curls framing the face, one eye hidden.
			_paper(PackedVector2Array([Vector2(-7.5, -33), Vector2(7.5, -34), Vector2(6, -30), Vector2(-2, -31.5), Vector2(-7, -29)]), hair)
			_draw_ellipse(Vector2(-7.2, -26.5), Vector2(2.6, 4.6), hair)
			_draw_ellipse(Vector2(7.2, -26.5), Vector2(2.6, 4.6), hair)
			_draw_ellipse(Vector2(-3.2, -30.5), Vector2(3.8, 2.6), hair)
		"short", "long":
			_paper(PackedVector2Array([Vector2(-7.5, -31), Vector2(-5, -36), Vector2(5, -36.5), Vector2(7.5, -31), Vector2(4, -33.5), Vector2(-4, -33.5)]), hair)
		"bun":
			_paper(PackedVector2Array([Vector2(-7.5, -30), Vector2(-5, -36), Vector2(5, -36), Vector2(7.5, -30), Vector2(0, -33)]), hair)
			_draw_circle_paper(Vector2(0, -38), 3.6, hair)
		"bald":
			pass

	# Face: red-rimmed eyes and, at the Bal, lips the colour of the dead.
	var eye: Color = _c(Color(0.12, 0.09, 0.1))
	draw_circle(head_center + Vector2(-2.6, -0.4), 0.85, eye)
	draw_circle(head_center + Vector2(2.6, -0.4), 0.85, eye)
	if l["lips"] != null:
		draw_line(head_center + Vector2(-1.6, 3.4), head_center + Vector2(1.6, 3.4), _c(l["lips"]), 1.3)

func _draw_hat(l: Dictionary) -> void:
	var hat: String = str(l["hat"])
	if hat == "none":
		return
	var color: Color = _c(l["hat_color"])
	var cockade_pos: Vector2 = Vector2(4, -37)
	match hat:
		"bicorne":
			_paper(PackedVector2Array([Vector2(-16, -33), Vector2(-9, -40), Vector2(0, -43), Vector2(9, -40), Vector2(16, -33), Vector2(7, -35), Vector2(0, -34.5), Vector2(-7, -35)]), color)
		"cloche":
			_paper(PackedVector2Array([Vector2(-10, -29), Vector2(-9, -37), Vector2(-4, -41), Vector2(4, -41), Vector2(9, -37), Vector2(10, -29), Vector2(0, -31.5)]), color)
			cockade_pos = Vector2(5, -35)
		"top":
			_paper(PackedVector2Array([Vector2(-6, -35), Vector2(-7, -49), Vector2(7, -49), Vector2(6, -35)]), color)
			_paper(PackedVector2Array([Vector2(-11, -35), Vector2(11, -35), Vector2(9, -33), Vector2(-9, -33)]), color.darkened(0.15))
			cockade_pos = Vector2(4, -39)
		"tricorne":
			_paper(PackedVector2Array([Vector2(-13, -33), Vector2(0, -42), Vector2(13, -33), Vector2(0, -36)]), color)
		"beret":
			_paper(PackedVector2Array([Vector2(-10, -32), Vector2(-7, -39), Vector2(4, -40), Vector2(11, -35), Vector2(8, -32)]), color)
			cockade_pos = Vector2(-4, -36)
		"cap":
			_paper(PackedVector2Array([Vector2(-8, -32), Vector2(-6, -38), Vector2(6, -38), Vector2(8, -32)]), color)
			_paper(PackedVector2Array([Vector2(-1, -32), Vector2(11, -31), Vector2(8, -29.5), Vector2(-1, -30)]), color.darkened(0.2), false)
		"bonnet":
			# The red Phrygian bonnet of 1793, worn by men who never stopped.
			_paper(PackedVector2Array([Vector2(-8, -31), Vector2(-7, -39), Vector2(2, -43), Vector2(9, -39), Vector2(6, -36), Vector2(8, -31)]), color)
	if l["cockade"] != null:
		_draw_cockade(cockade_pos, l["cockade"])

func _draw_cockade(at: Vector2, cockade: Variant) -> void:
	# A cockade is political: "tricolore" is the law, black is royalist.
	if typeof(cockade) == TYPE_STRING and str(cockade) == "tricolore":
		_draw_circle_paper(at, 3.0, _c(Color(0.18, 0.25, 0.6)))
		draw_circle(at, 2.0, _c(Color(0.95, 0.94, 0.9)))
		draw_circle(at, 1.0, _c(Color(0.75, 0.12, 0.14)))
		return
	var color: Color = cockade as Color
	_draw_circle_paper(at, 3.0, _c(color))
	draw_circle(at, 1.2, _c(color.darkened(0.5)))

# =========================================================
# PAPER PRIMITIVES
# =========================================================
func _c(value: Variant) -> Color:
	var color: Color = value as Color
	if flash_amount > 0.0:
		color = color.lerp(flash_color, flash_amount)
	return color

# A cut-paper shape: drop shadow, jittered fill and an ink outline.
func _paper(points: PackedVector2Array, color: Color, with_shadow: bool = true) -> void:
	var cut: PackedVector2Array = PackedVector2Array()
	for point in points:
		cut.append(point + Vector2(_rng.randf_range(-0.35, 0.35), _rng.randf_range(-0.35, 0.35)))
	if with_shadow:
		var shadow: PackedVector2Array = PackedVector2Array()
		for point in cut:
			shadow.append(point + SHADOW_OFFSET)
		draw_colored_polygon(shadow, SHADOW_COLOR)
	draw_colored_polygon(cut, color)
	var outline: PackedVector2Array = cut.duplicate()
	outline.append(cut[0])
	draw_polyline(outline, color.darkened(OUTLINE_DARKEN), 0.8)

func _draw_circle_paper(center: Vector2, radius: float, color: Color) -> void:
	_draw_ellipse(center, Vector2(radius, radius), color, true)

func _draw_ellipse(center: Vector2, radii: Vector2, color: Color, outlined: bool = false) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var steps: int = 14
	for i in range(steps):
		var a: float = TAU * i / steps
		points.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(points, color)
	if outlined:
		points.append(points[0])
		draw_polyline(points, color.darkened(OUTLINE_DARKEN), 0.8)

func _line(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	draw_line(from, to, color.darkened(OUTLINE_DARKEN), width + 0.9)
	draw_line(from, to, color, width)
