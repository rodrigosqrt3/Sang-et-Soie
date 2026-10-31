class_name SmugglerShop
extends RefCounted

# The Belgian's alterations, offered as a conversation generated from the
# current state: only what Étienne can still buy, at tonight's price.

const BASE_PRICE: int = 5
const EXPOSED_SURCHARGE: int = 2

const UPGRADES: Dictionary = {
	"dash": {
		"name": "A silk cravat",
		"pitch": "Lighter at the throat. You recover from a sprint sooner.",
		"result": "The silk settles around your throat. Movement feels less costly.",
	},
	"focus": {
		"name": "A polished monocle",
		"pitch": "Le Regard lasts longer before the world blurs.",
		"result": "The polished lens catches details that used to escape you.",
	},
	"cane": {
		"name": "Pouvoir exécutif",
		"pitch": "Lead in the cane, as the jeunesse dorée liked it. A broader strike.",
		"result": "Lead shifts inside the cane. Elegance acquires weight. Somewhere, Auguste changes key.",
	},
}

static func get_price() -> int:
	return BASE_PRICE + (EXPOSED_SURCHARGE if Global.exposure >= 3 else 0)

static func is_available(upgrade_id: String) -> bool:
	match upgrade_id:
		"dash": return Global.dash_cooldown >= 1.0
		"focus": return Global.focus_drain_rate >= 60.0
		"cane": return Global.weapon_scale == Vector2(1.0, 1.0)
	return false

static func open() -> void:
	var price: int = get_price()
	var nodes: Dictionary = {}
	var choices: Array = []
	for upgrade_id in UPGRADES.keys():
		if not is_available(upgrade_id):
			continue
		var upgrade: Dictionary = UPGRADES[upgrade_id]
		var label: String = str(upgrade["name"]) + " — " + str(upgrade["pitch"]) + " (" + str(price) + " F)"
		choices.append({"text": label, "if": ["francs>=" + str(price)], "next": "bought_" + upgrade_id,
			"effects": ["action:buy:" + upgrade_id]})
		choices.append({"text": label, "if": ["francs<" + str(price)], "next": "poor"})
		nodes["bought_" + upgrade_id] = {"speaker": "narrator", "text": str(upgrade["result"]) + "  ({francs} francs left.)", "next": "end"}
	choices.append({"text": "Not tonight.", "next": "bye"})

	var greeting: String = "Choose what kind of survivor you intend to be. You carry {francs} francs."
	if Global.exposure >= 3:
		greeting = "Prices rise when the police know your face, Étienne. " + str(price) + " francs apiece tonight. You carry {francs}."
	if choices.size() == 1:
		nodes["start"] = {"speaker": "belgian", "text": "Nothing else tonight, Étienne. Even decadence has an inventory.", "next": "end"}
	else:
		nodes["start"] = {"speaker": "belgian", "text": greeting, "choices": choices}
	nodes["poor"] = {"speaker": "belgian", "text": "Taste is expensive. Come back when your purse agrees with it.", "next": "end"}
	nodes["bye"] = {"speaker": "belgian", "text": "Then go carefully. I dislike losing customers.", "next": "end"}
	Dialogue.start_nodes(nodes, "start", "belgian_shop")

static func buy(upgrade_id: String) -> void:
	var price: int = get_price()
	if Global.francs < price or not is_available(upgrade_id):
		return
	Global.francs -= price
	match upgrade_id:
		"dash":
			Global.dash_cooldown = 0.6
		"focus":
			Global.focus_drain_rate = 35.0
		"cane":
			Global.weapon_scale = Vector2(1.4, 1.4)
			Global.add_counter("bought_pouvoir_executif", 1)
			for player in (Engine.get_main_loop() as SceneTree).get_nodes_in_group("player"):
				var pivot: Node2D = player.get_node_or_null("AttackPivot") as Node2D
				if pivot != null:
					pivot.scale = Global.weapon_scale
	Global.save_game()
