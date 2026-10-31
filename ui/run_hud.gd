extends CanvasLayer

# The HUD of every excursion, built in code in the paper style of the Bal.
# Levels talk to it through set_title / set_status / set_method / show_boss.

@export var area_title: String = "PARIS"

var title_label: Label
var objective_label: Label
var status_label: Label
var method_label: Label
var consequence_label: Label
var night_label: Label
var ribbons: RibbonMeter
var dash_bar: InkBar
var focus_bar: InkBar
var tools_label: Label
var boss_card: PaperCard
var boss_label: Label
var boss_bar: InkBar

func _ready() -> void:
	layer = 10
	add_to_group("run_hud")
	build()
	set_title(area_title)
	refresh_objective()

func build() -> void:
	var card: PaperCard = make_card(Vector2(14, 10), Vector2(392, 66))
	title_label = Label.new()
	title_label.position = Vector2(14, 5)
	title_label.label_settings = Style.caps_settings(17, Style.CANDLE)
	card.add_child(title_label)
	objective_label = Label.new()
	objective_label.position = Vector2(14, 31)
	objective_label.size = Vector2(368, 34)
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	style_label(objective_label, 13, Style.BONE, true)
	card.add_child(objective_label)

	status_label = Label.new()
	status_label.position = Vector2(20, 82)
	status_label.size = Vector2(560, 22)
	style_label(status_label, 13, Color("D9C89F"), true)
	add_child(status_label)

	var right: PaperCard = make_card(Vector2(560, 10), Vector2(226, 66))
	method_label = Label.new()
	method_label.position = Vector2(12, 6)
	method_label.size = Vector2(204, 20)
	method_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	method_label.label_settings = Style.caps_settings(13, Style.BONE)
	right.add_child(method_label)
	consequence_label = Label.new()
	consequence_label.position = Vector2(12, 26)
	consequence_label.size = Vector2(204, 18)
	consequence_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	style_label(consequence_label, 12, Color("C9A46A"), false)
	right.add_child(consequence_label)
	night_label = Label.new()
	night_label.position = Vector2(12, 44)
	night_label.size = Vector2(204, 18)
	night_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	style_label(night_label, 12, Style.BONE, true)
	right.add_child(night_label)

	# Bottom-left: the body. Ribbons for life, ink bars for breath and focus.
	var body: PaperCard = make_card(Vector2(14, 520), Vector2(250, 68))
	ribbons = RibbonMeter.new()
	ribbons.position = Vector2(8, 4)
	ribbons.size = Vector2(100, 28)
	body.add_child(ribbons)
	dash_bar = make_bar(body, Vector2(112, 10), "DASH")
	focus_bar = make_bar(body, Vector2(112, 26), "REGARD")
	focus_bar.fill_color = Color("7FC9B4")
	tools_label = Label.new()
	tools_label.position = Vector2(10, 42)
	tools_label.size = Vector2(232, 20)
	style_label(tools_label, 12, Color("A9C9BC"), false)
	body.add_child(tools_label)

	boss_card = make_card(Vector2(250, 88), Vector2(300, 46))
	boss_label = Label.new()
	boss_label.position = Vector2(0, 4)
	boss_label.size = Vector2(300, 18)
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.label_settings = Style.caps_settings(14, Color("E07A5F"))
	boss_card.add_child(boss_label)
	boss_bar = InkBar.new()
	boss_bar.position = Vector2(20, 26)
	boss_bar.size = Vector2(260, 9)
	boss_bar.fill_color = Style.RIBBON_RED
	boss_card.add_child(boss_bar)
	boss_card.visible = false

func make_card(at: Vector2, card_size: Vector2) -> PaperCard:
	var card: PaperCard = PaperCard.new()
	card.position = at
	card.size = card_size
	card.paper_color = Color("1C1416", 0.92)
	card.edge_color = Color("B8892E")
	card.shadow_alpha = 0.45
	card.fibre_count = 0
	card.jitter = 1.2
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(card)
	return card

func make_bar(parent: Control, at: Vector2, label_text: String) -> InkBar:
	var label: Label = Label.new()
	label.text = label_text
	label.position = at + Vector2(0, -5)
	label.label_settings = Style.caps_settings(10, Color("C9A46A"))
	parent.add_child(label)
	var bar: InkBar = InkBar.new()
	bar.position = at + Vector2(54, 1)
	bar.size = Vector2(72, 6)
	parent.add_child(bar)
	return bar

func style_label(label: Label, font_size: int, color: Color, italic: bool) -> void:
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if italic:
		label.add_theme_font_override("font", Style.font_italic)

# =========================================================
# API FOR LEVELS
# =========================================================
func set_title(text: String) -> void:
	title_label.text = text

func set_status(text: String, color: Color = Color("D9C89F")) -> void:
	status_label.text = text
	status_label.add_theme_color_override("font_color", color)

func set_method(text: String, color: Color) -> void:
	method_label.text = text
	method_label.label_settings.font_color = color

func show_boss(label_text: String, current: float, maximum: float) -> void:
	boss_card.visible = true
	boss_label.text = label_text
	boss_bar.max_value = maximum
	boss_bar.value = current

func hide_boss() -> void:
	boss_card.visible = false

func show_message(speaker: String, message: String, duration: float = 6.0) -> void:
	Dialogue.bark(speaker, message, duration)

func refresh_objective() -> void:
	objective_label.text = Global.get_current_objective()

func _process(_delta: float) -> void:
	refresh_objective()
	if method_label.text.is_empty():
		set_method("METHOD: DISCREET" if Global.violence == 0 else "METHOD: VIOLENT", Style.BONE)
	consequence_label.text = "Exposure " + str(Global.exposure) + "   ·   Violence " + str(Global.violence)
	night_label.text = Global.get_republican_date() + "  ·  " + str(Global.get_nights_remaining()) + " nights left"
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player: Node = players[0]
	ribbons.value = int(player.get("current_health"))
	focus_bar.value = float(player.get("current_focus"))
	var cooldown_timer: float = float(player.get("dash_cooldown_timer"))
	dash_bar.value = clampf((Global.dash_cooldown - cooldown_timer) / Global.dash_cooldown * 100.0, 0.0, 100.0)
	var coins: int = int(player.get("distraction_charges"))
	var stealth: String = str(player.call("get_stealth_state"))
	tools_label.text = "Coins [Q] " + "● ".repeat(coins) + "○ ".repeat(maxi(0, 3 - coins)) + "  ·  " + stealth.capitalize()
	match stealth:
		"HIDDEN": tools_label.add_theme_color_override("font_color", Color("7ED3A4"))
		"BLENDED": tools_label.add_theme_color_override("font_color", Color("9DB8E8"))
		_: tools_label.add_theme_color_override("font_color", Color("C9B8A0"))
