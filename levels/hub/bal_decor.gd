extends Node2D

# The Bal des Victimes, drawn in cut paper: velvet, black-and-bone marble,
# silhouettes of the guillotined on the walls, candles that never go out.
# Also places the furniture collisions and the candle lights, so the room's
# look and its physical shape always agree.

const ROOM: Vector2 = Vector2(800, 600)
const WALL_BOTTOM: float = 96.0
const DANCE_FLOOR: Rect2 = Rect2(170, 150, 460, 380)
const STAIRS: Rect2 = Rect2(350, 18, 100, 80)

const VELVET: Color = Color("3B0F18")
const VELVET_LIGHT: Color = Color("5A1A26")
const FLOOR_DARK: Color = Color("140D10")
const MARBLE_BONE: Color = Color("6C625A")
const MARBLE_BLACK: Color = Color("17110F")
const GILT: Color = Color("B8892E")
const CARPET: Color = Color("5E1420")

# Physical furniture: [position, size]. The drawing below matches these.
const FURNITURE: Array = [
	[Vector2(78, 215), Vector2(58, 118)],    # harpsichord
	[Vector2(220, 424), Vector2(104, 30)],   # Marguerite's table
	[Vector2(664, 192), Vector2(44, 38)],    # Arvène's armchair
	[Vector2(724, 432), Vector2(46, 42)],    # contraband crate
	[Vector2(748, 388), Vector2(38, 34)],    # contraband crate
	[Vector2(186, 166), Vector2(14, 14)],    # candle stands at the dance floor
	[Vector2(614, 166), Vector2(14, 14)],
	[Vector2(186, 514), Vector2(14, 14)],
	[Vector2(614, 514), Vector2(14, 14)],
]

const CANDLES: Array = [
	Vector2(40, 116), Vector2(760, 116),
	Vector2(186, 158), Vector2(614, 158), Vector2(186, 506), Vector2(614, 506),
	Vector2(250, 412), Vector2(692, 182),
]

func _ready() -> void:
	z_index = -20
	build_collisions()
	build_lights()
	queue_redraw()

func build_collisions() -> void:
	var walls: Array = [
		[Vector2(175, WALL_BOTTOM * 0.5), Vector2(350, WALL_BOTTOM)],
		[Vector2(625, WALL_BOTTOM * 0.5), Vector2(350, WALL_BOTTOM)],
		[Vector2(400, 8), Vector2(800, 16)],
		[Vector2(-8, 300), Vector2(16, 600)],
		[Vector2(808, 300), Vector2(16, 600)],
		[Vector2(400, 608), Vector2(800, 16)],
	]
	for entry in walls + FURNITURE:
		var body: StaticBody2D = StaticBody2D.new()
		body.position = entry[0]
		var shape: CollisionShape2D = CollisionShape2D.new()
		var rectangle: RectangleShape2D = RectangleShape2D.new()
		rectangle.size = entry[1]
		shape.shape = rectangle
		body.add_child(shape)
		add_child(body)

func build_lights() -> void:
	var holder: Node2D = Node2D.new()
	holder.z_index = 30
	add_child(holder)
	for candle in CANDLES:
		holder.add_child(CandleLight.make(candle, Color(1.0, 0.72, 0.42), 0.9, 0.75))
	# The chandelier: one broad, slow light over the dancers.
	var chandelier: CandleLight = CandleLight.make(Vector2(400, 330), Color(1.0, 0.8, 0.55), 0.85, 2.6)
	chandelier.flicker = 0.05
	chandelier.flicker_speed = 0.4
	holder.add_child(chandelier)

func _draw() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 1797
	draw_rect(Rect2(Vector2.ZERO, ROOM), FLOOR_DARK)
	PaperDraw.fibres(self, Rect2(Vector2(0, WALL_BOTTOM), ROOM), Color(1, 1, 1, 0.03), 120, rng, 18.0)
	draw_dance_floor(rng)
	draw_carpet(rng)
	draw_back_wall(rng)
	draw_harpsichord(rng)
	draw_table(rng)
	draw_armchair(rng)
	draw_contraband(rng)
	draw_candle_stands(rng)
	draw_quarry_grate(rng)

func draw_dance_floor(rng: RandomNumberGenerator) -> void:
	PaperDraw.rect(self, DANCE_FLOOR.grow(6), Color("2A1D19"), rng, Vector2(4, 5))
	# Diamond marble: alternating bone and black lozenges.
	var cell: float = 38.0
	var origin: Vector2 = DANCE_FLOOR.position
	var cols: int = int(DANCE_FLOOR.size.x / cell)
	var rows: int = int(DANCE_FLOOR.size.y / cell)
	for row in range(rows):
		for col in range(cols):
			var center: Vector2 = origin + Vector2(col + 0.5, row + 0.5) * cell + Vector2((DANCE_FLOOR.size.x - cols * cell) * 0.5, (DANCE_FLOOR.size.y - rows * cell) * 0.5)
			var half: float = cell * 0.5
			var diamond: PackedVector2Array = PackedVector2Array([
				center + Vector2(0, -half), center + Vector2(half, 0), center + Vector2(0, half), center + Vector2(-half, 0)])
			var bone: bool = (row + col) % 2 == 0
			var color: Color = MARBLE_BONE if bone else MARBLE_BLACK
			color = color.lerp(Color.BLACK, rng.randf_range(0.0, 0.12))
			draw_colored_polygon(PaperDraw.cut(diamond, rng, 0.6), color)
	# Veins in the marble.
	for i in range(26):
		var start: Vector2 = Vector2(rng.randf_range(DANCE_FLOOR.position.x, DANCE_FLOOR.end.x), rng.randf_range(DANCE_FLOOR.position.y, DANCE_FLOOR.end.y))
		var points: PackedVector2Array = PackedVector2Array([start])
		for j in range(4):
			points.append(points[points.size() - 1] + Vector2(rng.randf_range(4, 16), rng.randf_range(-6, 6)))
		draw_polyline(points, Color(0.85, 0.8, 0.72, 0.12), 1.0)
	draw_rect(DANCE_FLOOR, Color(GILT, 0.65), false, 2.0)

func draw_carpet(rng: RandomNumberGenerator) -> void:
	PaperDraw.rect(self, Rect2(368, WALL_BOTTOM - 4, 64, DANCE_FLOOR.position.y - WALL_BOTTOM + 8), CARPET, rng, Vector2(3, 3))
	draw_line(Vector2(374, WALL_BOTTOM), Vector2(374, DANCE_FLOOR.position.y), Color(GILT, 0.6), 1.5)
	draw_line(Vector2(426, WALL_BOTTOM), Vector2(426, DANCE_FLOOR.position.y), Color(GILT, 0.6), 1.5)

func draw_back_wall(rng: RandomNumberGenerator) -> void:
	draw_rect(Rect2(0, 0, ROOM.x, WALL_BOTTOM), VELVET)
	# Velvet folds: soft vertical bands.
	var x: float = 0.0
	while x < ROOM.x:
		var width: float = rng.randf_range(10, 18)
		draw_rect(Rect2(x, 0, width * 0.45, WALL_BOTTOM), Color(VELVET_LIGHT, 0.55))
		draw_line(Vector2(x + width - 1, 0), Vector2(x + width - 1, WALL_BOTTOM), Color(0, 0, 0, 0.35), 1.0)
		x += width
	# Gilt rail and the shadow it casts on the floor.
	draw_rect(Rect2(0, WALL_BOTTOM - 6, ROOM.x, 6), GILT.darkened(0.3))
	draw_rect(Rect2(0, WALL_BOTTOM, ROOM.x, 10), Color(0, 0, 0, 0.35))

	# The stairs up to the street, and the gold door.
	for step in range(5):
		var y: float = STAIRS.position.y + step * 15.0
		PaperDraw.rect(self, Rect2(STAIRS.position.x - step * 2, y, STAIRS.size.x + step * 4, 15), Color("2B211D").lightened(step * 0.04), rng, Vector2(0, 3))
	PaperDraw.rect(self, Rect2(370, 0, 60, 22), GILT.darkened(0.15), rng, Vector2(2, 3))

	# Silhouettes of the guillotined, in oval frames.
	var frames: Array[float] = [70.0, 150.0, 230.0, 310.0, 490.0, 570.0, 650.0, 730.0]
	for i in range(frames.size()):
		var center: Vector2 = Vector2(frames[i], 44)
		PaperDraw.ellipse(self, center, Vector2(19, 25), GILT, rng, Vector2(2, 3))
		PaperDraw.ellipse(self, center, Vector2(15, 21), Color("E4DCCB"), rng, Vector2.ZERO, false)
		PaperDraw.silhouette(self, center + Vector2(0, 3), 1.25, Color("120C0E"), i % 2 == 0)
		# A red ribbon across each frame: every face here was lost.
		draw_line(center + Vector2(-15, 10), center + Vector2(15, 6), Color("B3202C"), 2.0)

func draw_harpsichord(rng: RandomNumberGenerator) -> void:
	var c: Vector2 = Vector2(78, 215)
	# The wing-shaped case, seen from above, lid raised.
	var case_points: PackedVector2Array = PackedVector2Array([
		c + Vector2(-29, -59), c + Vector2(29, -59), c + Vector2(29, 10), c + Vector2(12, 59), c + Vector2(-14, 59), c + Vector2(-29, 40)])
	PaperDraw.poly(self, case_points, Color("1B1412"), rng, Vector2(5, 6))
	PaperDraw.poly(self, PackedVector2Array([c + Vector2(-24, -52), c + Vector2(24, -52), c + Vector2(24, 6), c + Vector2(9, 51), c + Vector2(-10, 51), c + Vector2(-24, 36)]), Color("6E5536"), rng, Vector2.ZERO)
	# Strings.
	for i in range(9):
		var x: float = -18.0 + i * 4.4
		draw_line(c + Vector2(x, -46), c + Vector2(x * 0.55, 46), Color(0.92, 0.85, 0.62, 0.55), 1.0)
	# Keyboard on the right edge, where Auguste sits.
	PaperDraw.rect(self, Rect2(c + Vector2(29, -56), Vector2(9, 44)), Color("E9E2D3"), rng, Vector2(1, 2))
	for i in range(8):
		draw_line(c + Vector2(29, -52 + i * 5.5), c + Vector2(38, -52 + i * 5.5), Color(0.1, 0.08, 0.08), 1.0)
	# The raised lid, gilt and painted.
	PaperDraw.poly(self, PackedVector2Array([c + Vector2(-29, -59), c + Vector2(-48, -50), c + Vector2(-46, 30), c + Vector2(-29, 40)]), GILT.darkened(0.2), rng, Vector2(3, 4))

func draw_table(rng: RandomNumberGenerator) -> void:
	var area: Rect2 = Rect2(Vector2(220, 424) - Vector2(52, 15), Vector2(104, 30))
	PaperDraw.rect(self, area, Color("3A2418"), rng, Vector2(4, 5))
	PaperDraw.rect(self, area.grow(-4), Color("E4DCCB"), rng, Vector2.ZERO, false)
	# Glasses and a bottle of Burgundy, for Madame.
	for i in range(5):
		PaperDraw.ellipse(self, area.position + Vector2(14 + i * 16, 15 + (i % 2) * 3), Vector2(3.5, 3.5), Color(0.82, 0.86, 0.88, 0.7), rng, Vector2(1, 1))
	PaperDraw.ellipse(self, area.position + Vector2(92, 13), Vector2(4.5, 4.5), Color("3B0F18"), rng, Vector2(1, 2))

func draw_armchair(rng: RandomNumberGenerator) -> void:
	var c: Vector2 = Vector2(664, 192)
	PaperDraw.rect(self, Rect2(c - Vector2(22, 19), Vector2(44, 38)), Color("5A1A26"), rng, Vector2(4, 5))
	PaperDraw.rect(self, Rect2(c - Vector2(22, 19), Vector2(44, 10)), Color("3B0F18"), rng, Vector2(0, 2))
	PaperDraw.rect(self, Rect2(c + Vector2(-16, -8), Vector2(32, 22)), Color("7A2836"), rng, Vector2.ZERO, false)

func draw_contraband(rng: RandomNumberGenerator) -> void:
	for crate in [[Vector2(724, 432), Vector2(46, 42)], [Vector2(748, 388), Vector2(38, 34)]]:
		var area: Rect2 = Rect2(crate[0] - crate[1] * 0.5, crate[1])
		PaperDraw.rect(self, area, Color("5C3F27"), rng, Vector2(4, 5))
		draw_line(area.position + Vector2(3, 3), area.end - Vector2(3, 3), Color("3A2618"), 2.0)
		draw_line(Vector2(area.end.x - 3, area.position.y + 3), Vector2(area.position.x + 3, area.end.y - 3), Color("3A2618"), 2.0)
	# A bolt of English muslin, very much illegal.
	PaperDraw.rect(self, Rect2(Vector2(690, 470), Vector2(56, 14)), Color("EEE9DD"), rng, Vector2(2, 3))

func draw_candle_stands(rng: RandomNumberGenerator) -> void:
	for candle in CANDLES:
		PaperDraw.ellipse(self, candle + Vector2(0, 6), Vector2(6, 4), GILT.darkened(0.25), rng, Vector2(2, 2))
		draw_rect(Rect2(candle + Vector2(-1.5, -6), Vector2(3, 10)), Color("EFE6CF"))
		PaperDraw.ellipse(self, candle + Vector2(0, -9), Vector2(2.2, 3.4), Color(1.0, 0.78, 0.35), rng, Vector2.ZERO, false)

func draw_quarry_grate(rng: RandomNumberGenerator) -> void:
	var area: Rect2 = Rect2(Vector2(128, 518), Vector2(46, 46))
	PaperDraw.rect(self, area.grow(4), Color("2A2624"), rng, Vector2(2, 3))
	draw_rect(area, Color("070606"))
	for i in range(6):
		var x: float = area.position.x + 4 + i * 7.5
		draw_line(Vector2(x, area.position.y + 2), Vector2(x, area.end.y - 2), Color("4A4744"), 2.0)
