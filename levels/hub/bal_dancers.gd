extends Node2D

# Couples waltzing on the marble. They keep dancing during conversations:
# the Bal never stops, whatever is said at its edges.

@export var couple_count: int = 4
@export var radius: Vector2 = Vector2(150, 105)
@export var orbit_speed: float = 0.22
@export var spin_speed: float = 2.1

var couples: Array[Dictionary] = []
var time: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Sorted together with the room's characters, so Étienne can pass in front
	# of or behind a couple naturally.
	y_sort_enabled = true
	for i in range(couple_count):
		var lead: PaperFigure = PaperFigure.new()
		var partner: PaperFigure = PaperFigure.new()
		var lead_look: Dictionary = CharacterData.get_crowd_look("palais", 40 + i * 2)
		var partner_look: Dictionary = CharacterData.get_crowd_look("palais", 41 + i * 2)
		# One Incroyable, one Merveilleuse per couple, all of them dead-lipped.
		lead_look["coat_style"] = "tails"
		lead_look["hair_style"] = "curls"
		partner_look["coat_style"] = "dress"
		partner_look["hair_style"] = "frizz"
		partner_look.erase("hat")
		partner_look.erase("accessory")
		lead_look["lips"] = Style.DEAD_BLUE
		partner_look["lips"] = Style.DEAD_BLUE
		lead.look = lead_look
		partner.look = partner_look
		lead.seed_id = 300 + i
		partner.seed_id = 400 + i
		add_child(lead)
		add_child(partner)
		couples.append({"lead": lead, "partner": partner, "phase": TAU * i / couple_count})

func _process(delta: float) -> void:
	time += delta
	for couple in couples:
		var phase: float = float(couple["phase"])
		var angle: float = phase + time * orbit_speed
		var center: Vector2 = Vector2(cos(angle) * radius.x, sin(angle) * radius.y)
		var spin: float = time * spin_speed + phase
		var offset: Vector2 = Vector2(cos(spin), sin(spin) * 0.45) * 11.0
		var lead: PaperFigure = couple["lead"]
		var partner: PaperFigure = couple["partner"]
		lead.position = center + offset
		partner.position = center - offset
		lead.facing_left = offset.x > 0.0
		partner.facing_left = offset.x < 0.0
		lead.moving_ratio = 0.35
		partner.moving_ratio = 0.35
