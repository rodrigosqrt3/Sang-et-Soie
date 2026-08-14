extends Node2D

@export_enum("west", "east") var sector_id: String = "west"
@export var sector_title: String = "PALAIS-ROYAL"
@export var contains_fragment: bool = false

const WEST_GALLERY_PATROL: Array[Vector2] = [
	Vector2(150, 170), Vector2(450, 170), Vector2(450, 330),
	Vector2(150, 330)
]
const WEST_SALON_PATROL: Array[Vector2] = [
	Vector2(620, 500), Vector2(880, 500), Vector2(880, 240),
	Vector2(620, 240)
]
const EAST_COURT_PATROL: Array[Vector2] = [
	Vector2(120, 180), Vector2(430, 180), Vector2(430, 510),
	Vector2(120, 510)
]
const EAST_SHOPS_PATROL: Array[Vector2] = [
	Vector2(570, 170), Vector2(880, 170), Vector2(880, 340),
	Vector2(570, 340)
]
const EAST_FRAGMENT_PATROL: Array[Vector2] = [
	Vector2(580, 520), Vector2(890, 520), Vector2(890, 410),
	Vector2(580, 410)
]
const EAST_FRAGMENT_SPOTS: Array[Vector2] = [
	Vector2(675, 110), Vector2(825, 385), Vector2(710, 585)
]

var fragment_collected_here: bool = false

@onready var score_label: Label = $UI/ScoreLabel
@onready var dash_bar: ProgressBar = $UI/DashBar
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var approach_label: Label = $UI/ApproachLabel
@onready var stealth_tools_label: Label = $UI/StealthToolsLabel
@onready var list_fragment: Area2D = get_node_or_null("ListFragment") as Area2D

func _ready() -> void:
	Global.register_palais_sector_visit(sector_id)
	restore_defeated_guards()
	configure_guards()
	configure_fragment()
	Global.position_player_at_pending_spawn(self)
	configure_camera_limits()
	apply_sector_memory()
	update_score_ui()

func restore_defeated_guards() -> void:
	var guard_names: Array[String] = []
	if sector_id == "west":
		guard_names = ["GuardGallery", "GuardSalon"]
	else:
		guard_names = ["GuardCourt", "GuardShops", "GuardFragment"]
	for guard_name in guard_names:
		if not Global.is_palais_guard_defeated(sector_id, guard_name):
			continue
		var guard: Node = get_node_or_null(guard_name)
		if guard != null:
			guard.process_mode = Node.PROCESS_MODE_DISABLED
			guard.queue_free()

func apply_sector_memory() -> void:
	var alert_level: int = Global.get_palais_sector_alert(sector_id)
	var search_origin: Vector2 = get_player_position()
	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		if not is_ancestor_of(enemy_node):
			continue
		if enemy_node.has_method("apply_district_alert"):
			enemy_node.call("apply_district_alert", alert_level, search_origin)
	set_local_crowds_disturbed(Global.is_palais_crowd_disturbed(sector_id))

func get_player_position() -> Vector2:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return Vector2(500, 350)
	var player: Node2D = players[0] as Node2D
	if player == null:
		return Vector2(500, 350)
	return player.global_position

func set_local_crowds_disturbed(value: bool) -> void:
	for crowd_node in get_tree().get_nodes_in_group("crowds"):
		if not is_ancestor_of(crowd_node):
			continue
		if crowd_node.has_method("set_disturbed"):
			crowd_node.call("set_disturbed", value)

func configure_camera_limits() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player: Node = players[0]
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1000
	camera.limit_bottom = 700
	camera.limit_smoothed = true

func configure_guards() -> void:
	if sector_id == "west":
		assign_patrol(get_node_or_null("GuardGallery"), WEST_GALLERY_PATROL)
		assign_patrol(get_node_or_null("GuardSalon"), WEST_SALON_PATROL)
	else:
		assign_patrol(get_node_or_null("GuardCourt"), EAST_COURT_PATROL)
		assign_patrol(get_node_or_null("GuardShops"), EAST_SHOPS_PATROL)
		assign_patrol(get_node_or_null("GuardFragment"), EAST_FRAGMENT_PATROL)

func assign_patrol(guard: Node, route_points: Array[Vector2]) -> void:
	if guard != null and guard.has_method("set_patrol_route"):
		guard.call("set_patrol_route", route_points)

func configure_fragment() -> void:
	if list_fragment == null:
		return
	var fragment_active: bool = (
		contains_fragment
		and Global.current_quest == "enter_streets"
		and not Global.has_list_fragment
	)
	if fragment_active:
		var spot_index: int = randi_range(0, EAST_FRAGMENT_SPOTS.size() - 1)
		list_fragment.position = EAST_FRAGMENT_SPOTS[spot_index]
	else:
		list_fragment.visible = false
		list_fragment.monitoring = false
		list_fragment.process_mode = Node.PROCESS_MODE_DISABLED

func add_score(_amount: int) -> void:
	update_score_ui()

func register_detection() -> void:
	Global.register_palais_detection(sector_id)
	set_local_crowds_disturbed(true)
	update_score_ui()

func register_guard_defeat(guard_id: String) -> void:
	Global.mark_palais_guard_defeated(sector_id, guard_id)
	set_local_crowds_disturbed(true)
	update_score_ui()

func collect_list_fragment() -> void:
	if fragment_collected_here or Global.has_list_fragment:
		return
	fragment_collected_here = true
	Global.has_list_fragment = true
	Global.fragment_recovered_without_killing = Global.palais_run_violence == 0
	Global.save_game()
	update_score_ui()

func update_score_ui() -> void:
	var alert_suffix: String = get_alert_suffix()
	if Global.current_quest != "enter_streets":
		score_label.text = sector_title + "  |  The arcades remember every footstep" + alert_suffix
	elif Global.has_list_fragment:
		score_label.text = "FRAGMENT SECURED. RETURN TO THE WESTERN GRATE.  |  Violence: " + str(Global.palais_run_violence) + alert_suffix
	elif contains_fragment:
		score_label.text = sector_title + "  |  Search for the courier's red wax" + alert_suffix
	else:
		score_label.text = sector_title + "  |  Find a route into the eastern arcade" + alert_suffix

	if Global.palais_run_violence > 0:
		approach_label.text = "METHOD: VIOLENT  |  Exposure: " + str(Global.exposure)
		approach_label.modulate = Color(0.88, 0.32, 0.28)
	elif Global.palais_run_detected:
		approach_label.text = "METHOD: COMPROMISED  |  Exposure: " + str(Global.exposure)
		approach_label.modulate = Color(0.94, 0.68, 0.24)
	else:
		approach_label.text = "METHOD: DISCREET  |  Exposure: " + str(Global.exposure)
		approach_label.modulate = Color(0.82, 0.72, 0.48)

func get_alert_suffix() -> String:
	var alert_level: int = Global.get_palais_sector_alert(sector_id)
	if alert_level >= 2:
		return "  |  DISTRICT ALARM"
	if alert_level == 1:
		return "  |  GUARDS WATCHFUL"
	return ""

func _process(delta: float) -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player: CharacterBody2D = players[0] as CharacterBody2D
	if player == null:
		return

	health_bar.value = player.current_health
	dash_bar.value = (Global.dash_cooldown - player.dash_cooldown_timer) / Global.dash_cooldown * 100.0
	var focus_bar: ProgressBar = $UI/FocusBar
	focus_bar.value = player.current_focus

	var filter: ColorRect = $UI/MonocleFilter
	if player.is_using_monocle:
		filter.color.a = move_toward(filter.color.a, 0.4, delta * 3.0)
	else:
		filter.color.a = move_toward(filter.color.a, 0.0, delta * 5.0)

	var coins: int = int(player.get("distraction_charges"))
	var stealth_state: String = str(player.call("get_stealth_state"))
	if stealth_state == "HIDDEN":
		stealth_tools_label.text = "COINS [Q]: " + str(coins) + "  |  HIDDEN"
		stealth_tools_label.modulate = Color(0.46, 0.82, 0.62)
	elif stealth_state == "BLENDED":
		stealth_tools_label.text = "COINS [Q]: " + str(coins) + "  |  BLENDED"
		stealth_tools_label.modulate = Color(0.58, 0.72, 0.92)
	else:
		stealth_tools_label.text = "COINS [Q]: " + str(coins) + "  |  EXPOSED"
		stealth_tools_label.modulate = Color(0.72, 0.68, 0.58)