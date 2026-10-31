extends CanvasLayer

# The Bal's quiet overlay: the date by the Republican calendar, the nights left
# before the 20th of Frimaire, the objective, and Étienne's two voices.

var date_label: Label
var nights_label: Label
var objective_label: Label
var voices_label: RichTextLabel

func _ready() -> void:
	layer = 10
	var card: PaperCard = PaperCard.new()
	card.position = Vector2(16, 12)
	card.size = Vector2(330, 86)
	card.paper_color = Color("1C1416")
	card.edge_color = Color("B8892E")
	card.shadow_alpha = 0.5
	card.fibre_count = 0
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(card)

	var title: Label = Label.new()
	title.text = "BAL DES VICTIMES"
	title.position = Vector2(14, 6)
	title.label_settings = Style.caps_settings(20, Style.CANDLE)
	card.add_child(title)

	date_label = Label.new()
	date_label.position = Vector2(14, 32)
	date_label.add_theme_font_override("font", Style.font_italic)
	date_label.add_theme_font_size_override("font_size", 14)
	date_label.add_theme_color_override("font_color", Style.BONE)
	card.add_child(date_label)

	nights_label = Label.new()
	nights_label.position = Vector2(14, 54)
	nights_label.add_theme_font_size_override("font_size", 13)
	nights_label.add_theme_color_override("font_color", Color("C9A46A"))
	card.add_child(nights_label)

	objective_label = Label.new()
	objective_label.position = Vector2(20, 566)
	objective_label.size = Vector2(760, 24)
	objective_label.add_theme_font_override("font", Style.font_italic)
	objective_label.add_theme_font_size_override("font_size", 15)
	objective_label.add_theme_color_override("font_color", Style.BONE)
	add_child(objective_label)

	voices_label = RichTextLabel.new()
	voices_label.bbcode_enabled = true
	voices_label.fit_content = true
	voices_label.scroll_active = false
	voices_label.position = Vector2(560, 18)
	voices_label.size = Vector2(224, 28)
	voices_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	voices_label.add_theme_font_override("normal_font", Style.font_caps)
	voices_label.add_theme_font_size_override("normal_font_size", 14)
	add_child(voices_label)

func _process(_delta: float) -> void:
	date_label.text = Global.get_republican_date() + "  ·  " + Global.get_gregorian_date()
	var left: int = Global.get_nights_remaining()
	nights_label.text = str(left) + (" night remains" if left == 1 else " nights remain") + " until the 20th of Frimaire"
	objective_label.text = "» " + Global.get_current_objective()
	var soie: int = Global.get_counter("soie")
	var sang: int = Global.get_counter("sang")
	voices_label.text = "[right][color=#3FA383]La Soie " + str(soie) + "[/color]   [color=#C0394A]Le Sang " + str(sang) + "[/color][/right]"
