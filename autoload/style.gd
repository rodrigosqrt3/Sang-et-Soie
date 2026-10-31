extends Node

# Palette and typography shared by every screen. Values follow
# docs/art_direction.md, section 3.

const BAL_BLACK: Color = Color("0E0B0D")
const BONE: Color = Color("E9E2D3")
const BONE_DARK: Color = Color("CFC5B0")
const INK: Color = Color("2A2320")
const INK_SOFT: Color = Color("5A4E46")
const CANDLE: Color = Color("E0A84A")
const DEAD_BLUE: Color = Color("4F7FC4")
const EMERALD: Color = Color("1F6B5A")
const VIOLET: Color = Color("6A3A8C")
const OCHRE: Color = Color("B8922E")
const BURGUNDY: Color = Color("6E1E2B")
const RIBBON_RED: Color = Color("B3202C")
const RUST: Color = Color("A5532A")
const HERRINGBONE: Color = Color("4A4744")
const OLIVE: Color = Color("5E6340")
const MUD: Color = Color("3A2C22")

# Étienne's two voices.
const SOIE_COLOR: Color = Color("2E7D62")
const SANG_COLOR: Color = Color("9E2633")

var font_regular: Font
var font_italic: Font
var font_caps: Font
var theme: Theme

func _ready() -> void:
	font_regular = load_font("res://assets/fonts/IMFellEnglish-Regular.ttf")
	font_italic = load_font("res://assets/fonts/IMFellEnglish-Italic.ttf")
	font_caps = load_font("res://assets/fonts/IMFellEnglishSC-Regular.ttf")
	theme = build_theme()
	get_tree().root.theme = theme

func load_font(path: String) -> Font:
	if ResourceLoader.exists(path):
		return load(path) as Font
	return ThemeDB.fallback_font

func build_theme() -> Theme:
	var built: Theme = Theme.new()
	built.default_font = font_regular
	built.default_font_size = 16

	built.set_color("font_color", "Label", BONE)
	built.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.55))
	built.set_constant("shadow_offset_x", "Label", 1)
	built.set_constant("shadow_offset_y", "Label", 1)

	var flat: StyleBoxFlat = StyleBoxFlat.new()
	flat.bg_color = Color(0, 0, 0, 0)
	flat.content_margin_left = 6
	flat.content_margin_right = 6
	var hover: StyleBoxFlat = flat.duplicate()
	hover.bg_color = Color(INK, 0.08)
	for state in ["normal", "pressed", "disabled", "focus"]:
		built.set_stylebox(state, "Button", flat)
	built.set_stylebox("hover", "Button", hover)
	built.set_color("font_color", "Button", INK)
	built.set_color("font_hover_color", "Button", BURGUNDY)
	built.set_color("font_pressed_color", "Button", RIBBON_RED)
	built.set_color("font_focus_color", "Button", BURGUNDY)

	# Thin ink-and-paper bars for health, dash and focus.
	var bar_bg: StyleBoxFlat = StyleBoxFlat.new()
	bar_bg.bg_color = Color(BAL_BLACK, 0.7)
	bar_bg.border_color = Color(BONE, 0.55)
	bar_bg.set_border_width_all(1)
	var bar_fill: StyleBoxFlat = StyleBoxFlat.new()
	bar_fill.bg_color = BONE
	built.set_stylebox("background", "ProgressBar", bar_bg)
	built.set_stylebox("fill", "ProgressBar", bar_fill)
	return built

func caps_settings(size: int, color: Color) -> LabelSettings:
	var settings: LabelSettings = LabelSettings.new()
	settings.font = font_caps
	settings.font_size = size
	settings.font_color = color
	return settings
