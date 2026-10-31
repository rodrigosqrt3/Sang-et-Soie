extends DistrictLevel

# The three rooms of the Palais-Égalité. They share one alert network: noise in
# one arcade puts the guards of the others on watch, and the dead stay dead
# for the rest of the excursion.

@export_enum("garden", "west", "east") var sector_id: String = "garden"

const SECTOR_GUARDS: Dictionary = {
	"garden": ["GuardWest", "GuardGarden", "GuardEast"],
	"west": ["GuardGallery", "GuardSalon"],
	"east": ["GuardCourt", "GuardShops", "GuardFragment"],
}
const SPAWNER_SCRIPT: String = "res://actors/enemies/enemy_spawner.gd"
const ESCAPE_SCENE: String = "res://levels/palais_royal/escape_route.tscn"
const FRAGMENT_SCENE: String = "res://levels/palais_royal/list_fragment.tscn"

var fragment_collected_here: bool = false

func on_level_ready() -> void:
	Global.register_palais_sector_visit(sector_id)
	restore_defeated_guards()
	if sector_id == "garden":
		build_spawner()
		if Global.current_quest == Global.QUEST_ENTER_STREETS and Global.has_list_fragment:
			begin_return_phase()
		if Global.current_quest == Global.QUEST_ENTER_STREETS and not Global.has_flag("seen:palais_arrival"):
			Dialogue.bark_conversation("palais_arrival", 5.5)
	if sector_id == "east":
		place_fragment()
	apply_sector_memory()
	update_status()

func restore_defeated_guards() -> void:
	for guard_name in SECTOR_GUARDS.get(sector_id, []) as Array:
		if Global.is_palais_guard_defeated(sector_id, str(guard_name)):
			remove_guard(str(guard_name))

func apply_sector_memory() -> void:
	var alert_level: int = Global.get_palais_sector_alert(sector_id)
	var origin: Vector2 = player.global_position if player != null else Vector2(400, 300)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_ancestor_of(enemy) and enemy.has_method("apply_district_alert"):
			enemy.call("apply_district_alert", alert_level, origin)
	set_crowds_disturbed(Global.is_palais_crowd_disturbed(sector_id))

func set_crowds_disturbed(value: bool) -> void:
	for crowd in get_tree().get_nodes_in_group("crowds"):
		if is_ancestor_of(crowd) and crowd.has_method("set_disturbed"):
			crowd.call("set_disturbed", value)

# =========================================================
# THE PAGE (eastern arcade)
# =========================================================
func place_fragment() -> void:
	var spots: Array = get_markers("F")
	if spots.is_empty() or Global.current_quest != Global.QUEST_ENTER_STREETS or Global.has_list_fragment:
		return
	var index: int = Global.choose_palais_fragment_spot(spots.size())
	var fragment: Node2D = (load(FRAGMENT_SCENE) as PackedScene).instantiate() as Node2D
	fragment.name = "ListFragment"
	fragment.position = spots[index]
	add_child(fragment)

func collect_list_fragment() -> void:
	if fragment_collected_here or Global.has_list_fragment:
		return
	fragment_collected_here = true
	Global.has_list_fragment = true
	Global.fragment_recovered_without_killing = Global.palais_run_violence == 0
	Global.save_game()
	Dialogue.bark("etienne", "Red wax, a crow pressed into it. Jacquet's page. Now: back to the garden grate, quietly.", 5.0)
	update_status()

# =========================================================
# THE RETURN (garden)
# =========================================================
func build_spawner() -> void:
	var spawner: Node2D = Node2D.new()
	spawner.name = "EnemySpawner"
	var timer: Timer = Timer.new()
	timer.name = "SpawnTimer"
	spawner.add_child(timer)
	spawner.set_script(load(SPAWNER_SCRIPT))
	add_child(spawner)

func begin_return_phase() -> void:
	var spawner: Node = get_node_or_null("EnemySpawner")
	if spawner != null and spawner.has_method("begin_escape"):
		spawner.call("begin_escape")
	if get_node_or_null("EscapeRoute") != null:
		return
	var points: Array = get_markers("E")
	var escape: Node2D = (load(ESCAPE_SCENE) as PackedScene).instantiate() as Node2D
	escape.name = "EscapeRoute"
	escape.position = points[0] if not points.is_empty() else Vector2(80, 520)
	add_child(escape)

# =========================================================
# CALLBACKS FROM GUARDS, MARKS AND THE HUD
# =========================================================
func register_detection() -> void:
	Global.register_palais_detection(sector_id)
	set_crowds_disturbed(true)
	update_status()

func register_guard_defeat(guard_id: String) -> void:
	Global.mark_palais_guard_defeated(sector_id, guard_id)
	set_crowds_disturbed(true)
	update_status()

func add_score(_amount: int) -> void:
	update_status()

func register_secret_discovery(_shortcut_id: String) -> void:
	Dialogue.bark("etienne", "A mason's mark, and a latch behind it. The covered passage is open.", 4.5)
	update_status()

func update_status() -> void:
	var alert_level: int = Global.get_palais_sector_alert(sector_id)
	var suffix: String = "  ·  The district is roused" if alert_level >= 2 else ("  ·  The guards are watchful" if alert_level == 1 else "")
	if Global.current_quest != Global.QUEST_ENTER_STREETS:
		set_status("The arcades remember every footstep" + suffix)
	elif Global.has_list_fragment:
		set_status("The page is in your coat. Return to the garden's south-west corner." + suffix, Color("E0C27A"))
	elif sector_id == "east":
		set_status("Search the arcade for red wax: Jacquet's page" + suffix)
	elif sector_id == "west" and not Global.is_shortcut_unlocked("palais_covered_passage"):
		set_status("Le Regard may find another way into the eastern arcade" + suffix)
	else:
		set_status("Reach the eastern arcade, where Jacquet fell" + suffix)

	if Global.palais_run_violence > 0:
		set_method("METHOD: VIOLENT", Color("E05A48"))
	elif Global.palais_run_detected:
		set_method("METHOD: COMPROMISED", Color("F0AE3D"))
	else:
		set_method("METHOD: DISCREET", Color("D9C89F"))
