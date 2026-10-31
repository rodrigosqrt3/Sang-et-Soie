extends Node2D
class_name PropArt

# Cut-paper drawings for small objects. Gameplay nodes keep their old
# ColorRects hidden for compatibility and show one of these instead.

@export var kind: String = "crate":
	set(value):
		kind = value
		queue_redraw()
@export var state: String = "":
	set(value):
		state = value
		queue_redraw()
@export var tint: Color = Color.WHITE:
	set(value):
		tint = value
		queue_redraw()

var seed_id: int = 1

static func attach(parent: Node, prop_kind: String) -> PropArt:
	var art: PropArt = PropArt.new()
	art.kind = prop_kind
	art.seed_id = absi(str(parent.get_path()).hash()) % 991
	parent.add_child(art)
	return art

func _draw() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_id * 3331
	match kind:
		"crate": draw_crate(rng)
		"champagne": draw_champagne(rng)
		"trap": draw_trap(rng)
		"passage": draw_passage(rng)
		"escape": draw_escape(rng)
		"ledger": draw_ledger(rng)

func draw_crate(rng: RandomNumberGenerator) -> void:
	PaperDraw.rect(self, Rect2(-16, -16, 32, 32), Color("6B4A2C"), rng, Vector2(3, 4))
	draw_rect(Rect2(-13, -13, 26, 26), Color("3D2816"), false, 1.5)
	draw_line(Vector2(-13, -13), Vector2(13, 13), Color("3D2816"), 2.0)
	draw_line(Vector2(13, -13), Vector2(-13, 13), Color("3D2816"), 2.0)
	# A stencilled mark: contraband, of course.
	draw_string(Style.font_caps, Vector2(-9, 4), "VIN", HORIZONTAL_ALIGNMENT_LEFT, 20, 9, Color("D9C89F", 0.7))

func draw_champagne(rng: RandomNumberGenerator) -> void:
	PaperDraw.ellipse(self, Vector2(0, 11), Vector2(6, 2.5), Color(0, 0, 0, 0.35), rng, Vector2.ZERO, false)
	PaperDraw.poly(self, PackedVector2Array([Vector2(-4, 10), Vector2(4, 10), Vector2(4, -2), Vector2(2, -6), Vector2(2, -11), Vector2(-2, -11), Vector2(-2, -6), Vector2(-4, -2)]), Color("1F4A35"), rng, Vector2(2, 2))
	draw_rect(Rect2(-2.2, -13, 4.4, 3), Color("D8B04A"))
	draw_rect(Rect2(-4, 0, 8, 5), Color("E9E2D3"))

func draw_trap(rng: RandomNumberGenerator) -> void:
	# An iron plate in the floor; the spikes rise when it springs.
	var plate: Color = Color("3E4248").lerp(tint, 0.35)
	PaperDraw.rect(self, Rect2(-15, -15, 30, 30), plate, rng, Vector2(2, 2))
	for i in range(3):
		for j in range(3):
			var c: Vector2 = Vector2(-9 + i * 9, -9 + j * 9)
			if state == "active":
				draw_colored_polygon(PackedVector2Array([c + Vector2(-3, 3), c + Vector2(3, 3), c + Vector2(0, -6)]), Color("D9DCDF"))
			else:
				draw_circle(c, 1.8, Color(0, 0, 0, 0.6))
	if state == "warning":
		draw_rect(Rect2(-15, -15, 30, 30), Color(0.9, 0.3, 0.2, 0.35))

func draw_passage(rng: RandomNumberGenerator) -> void:
	# A stone archway: open, or barred with iron when locked.
	PaperDraw.rect(self, Rect2(-26, -30, 52, 54), Color("8C7F66"), rng, Vector2(4, 5))
	var opening: PackedVector2Array = PackedVector2Array([Vector2(-17, 22)])
	for i in range(11):
		var a: float = PI + PI * i / 10.0
		opening.append(Vector2(cos(a) * 17, -6 + sin(a) * 16))
	opening.append(Vector2(17, 22))
	draw_colored_polygon(opening, Color("120D0B"))
	draw_polyline(opening, Color("3A3226"), 1.5)
	PaperDraw.rect(self, Rect2(-30, -34, 60, 8), Color("B8892E").darkened(0.2), rng, Vector2(2, 3))
	if state == "locked":
		for i in range(5):
			var x: float = -12 + i * 6
			draw_line(Vector2(x, -18), Vector2(x, 22), Color("4A4744"), 2.5)
		draw_line(Vector2(-16, 4), Vector2(16, 4), Color("4A4744"), 2.5)
	else:
		draw_rect(Rect2(-14, 8, 28, 14), Color(1.0, 0.75, 0.4, 0.12))

func draw_escape(rng: RandomNumberGenerator) -> void:
	# The little garden gate Jacquet used, left ajar.
	PaperDraw.rect(self, Rect2(-20, -20, 40, 40), Color("2A2624"), rng, Vector2(2, 3))
	for i in range(6):
		draw_line(Vector2(-16 + i * 6.4, -16), Vector2(-16 + i * 6.4, 16), Color("6E6A62"), 2.0)
	draw_rect(Rect2(-20, -20, 40, 40), Color(1.0, 0.8, 0.4, 0.25 + 0.15 * sin(Time.get_ticks_msec() * 0.004)))

func draw_ledger(rng: RandomNumberGenerator) -> void:
	PaperDraw.rect(self, Rect2(-14, -10, 28, 20), Color("5A2A1C"), rng, Vector2(3, 4))
	PaperDraw.rect(self, Rect2(-12, -8, 12, 16), Color("E9E2D3"), rng, Vector2.ZERO, false)
	PaperDraw.rect(self, Rect2(0, -8, 12, 16), Color("E1D8C4"), rng, Vector2.ZERO, false)
	for i in range(4):
		draw_line(Vector2(-10, -5 + i * 4), Vector2(-2, -5 + i * 4), Color(0.2, 0.15, 0.12, 0.6), 1.0)
		draw_line(Vector2(2, -5 + i * 4), Vector2(10, -5 + i * 4), Color(0.2, 0.15, 0.12, 0.6), 1.0)

func _process(_delta: float) -> void:
	if kind == "escape":
		queue_redraw()
