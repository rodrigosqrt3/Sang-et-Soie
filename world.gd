extends Node2D

# This excursion is about recovering information, not clearing an arena.
var score: int = 0
var fragment_collected: bool = false
var detected_this_run: bool = false
var fragment_mission_active: bool = false

const SECTOR_ID: String = "garden"

const WEST_PATROL: Array[Vector2] = [
	Vector2(165, 190),
	Vector2(165, 260),
	Vector2(165, 390),
	Vector2(165, 500),
	Vector2(70, 500),
	Vector2(70, 390),
	Vector2(70, 210)
]
const GARDEN_PATROL: Array[Vector2] = [
	Vector2(275, 175),
	Vector2(525, 175),
	Vector2(525, 435),
	Vector2(275, 435)
]
const EAST_PATROL: Array[Vector2] = [
	Vector2(630, 180),
	Vector2(750, 180),
	Vector2(750, 500),
	Vector2(630, 500),
	Vector2(630, 385)
]

# Reference to the UI label
@onready var score_label: Label = $UI/ScoreLabel
@onready var dash_bar: ProgressBar = $UI/DashBar
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var approach_label: Label = $UI/ApproachLabel
@onready var stealth_tools_label: Label = $UI/StealthToolsLabel

func _ready() -> void:
	score = Global.palais_run_violence
	detected_this_run = Global.palais_run_detected
	fragment_mission_active = Global.current_quest == "enter_streets" and not Global.has_list_fragment
	Global.register_palais_sector_visit(SECTOR_ID)
	restore_defeated_guards()
	configure_guard_patrols()
	Global.position_player_at_pending_spawn(self)
	configure_camera_limits()
	apply_sector_memory()
	if Global.current_quest == "enter_streets" and Global.has_list_fragment:
		begin_return_phase()
	update_score_ui()

func restore_defeated_guards() -> void:
	var guard_names: Array[String] = ["GuardWest", "GuardGarden", "GuardEast"]
	for guard_name in guard_names:
		if not Global.is_palais_guard_defeated(SECTOR_ID, guard_name):
			continue
		var guard: Node = get_node_or_null(guard_name)
		if guard != null:
			guard.process_mode = Node.PROCESS_MODE_DISABLED
			guard.queue_free()

func apply_sector_memory() -> void:
	var alert_level: int = Global.get_palais_sector_alert(SECTOR_ID)
	var search_origin: Vector2 = get_player_position()
	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		if not is_ancestor_of(enemy_node):
			continue
		if enemy_node.has_method("apply_district_alert"):
			enemy_node.call("apply_district_alert", alert_level, search_origin)
	set_local_crowds_disturbed(Global.is_palais_crowd_disturbed(SECTOR_ID))

func get_player_position() -> Vector2:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return Vector2(400, 300)
	var player: Node2D = players[0] as Node2D
	if player == null:
		return Vector2(400, 300)
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
	camera.limit_right = 800
	camera.limit_bottom = 600
	camera.limit_smoothed = true

func configure_guard_patrols() -> void:
	assign_patrol($GuardWest, WEST_PATROL)
	assign_patrol($GuardGarden, GARDEN_PATROL)
	assign_patrol($GuardEast, EAST_PATROL)

func assign_patrol(guard: Node, route_points: Array[Vector2]) -> void:
	if guard.has_method("set_patrol_route"):
		guard.call("set_patrol_route", route_points)

# Defeating guards is optional and increases persistent consequences.
func add_score(_amount: int) -> void:
	score = Global.palais_run_violence
	update_score_ui()

# Updates the text shown on screen
func update_score_ui() -> void:
	var alert_suffix: String = get_alert_suffix()
	if Global.current_quest != "enter_streets":
		score_label.text = "PALAIS-ROYAL  |  The old passage runs beneath the arcades" + alert_suffix
	elif Global.has_list_fragment:
		score_label.text = "FRAGMENT SECURED. RETURN TO THE GRATE.  |  Violence: " + str(score) + alert_suffix
	else:
		score_label.text = "Search the eastern arcade for the stolen fragment  |  Violence: " + str(score) + alert_suffix

	if score > 0:
		approach_label.text = "METHOD: VIOLENT  |  Exposure: " + str(Global.exposure)
		approach_label.modulate = Color(0.88, 0.32, 0.28)
	elif detected_this_run:
		approach_label.text = "METHOD: COMPROMISED  |  Exposure: " + str(Global.exposure)
		approach_label.modulate = Color(0.94, 0.68, 0.24)
	else:
		approach_label.text = "METHOD: DISCREET  |  Exposure: " + str(Global.exposure)
		approach_label.modulate = Color(0.82, 0.72, 0.48)

func register_detection() -> void:
	Global.register_palais_detection(SECTOR_ID)
	detected_this_run = Global.palais_run_detected
	set_local_crowds_disturbed(true)
	update_score_ui()

func register_guard_defeat(guard_id: String) -> void:
	Global.mark_palais_guard_defeated(SECTOR_ID, guard_id)
	score = Global.palais_run_violence
	set_local_crowds_disturbed(true)
	update_score_ui()

func get_alert_suffix() -> String:
	var alert_level: int = Global.get_palais_sector_alert(SECTOR_ID)
	if alert_level >= 2:
		return "  |  DISTRICT ALARM"
	if alert_level == 1:
		return "  |  GUARDS WATCHFUL"
	return ""

func collect_list_fragment() -> void:
	if fragment_collected or not fragment_mission_active:
		return

	fragment_collected = true
	Global.has_list_fragment = true
	Global.fragment_recovered_without_killing = Global.palais_run_violence == 0
	begin_return_phase()
	Global.save_game()
	update_score_ui()

func begin_return_phase() -> void:
	fragment_collected = true

	var spawner: Node = $EnemySpawner
	if spawner and spawner.has_method("begin_escape"):
		spawner.call("begin_escape")

	if get_node_or_null("EscapeRoute") != null:
		return
	var escape_scene: PackedScene = load("res://escape_route.tscn") as PackedScene
	var escape_route: Area2D = escape_scene.instantiate() as Area2D
	escape_route.name = "EscapeRoute"
	escape_route.global_position = Vector2(80, 520)
	add_child(escape_route)

func _process(_delta: float) -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player: CharacterBody2D = players[0] as CharacterBody2D
		
		# Update standard HUD
		health_bar.value = player.current_health
		dash_bar.value = (Global.dash_cooldown - player.dash_cooldown_timer) / Global.dash_cooldown * 100.0
		
		# Update Focus Bar
		var focus_bar: ProgressBar = $UI/FocusBar
		focus_bar.value = player.current_focus
		
		# Fade the dark screen filter in and out based on Monocle usage
		var filter: ColorRect = $UI/MonocleFilter
		if player.is_using_monocle:
			# Lerp smoothly darkens the screen with a purple/blue tint
			filter.color.a = move_toward(filter.color.a, 0.4, _delta * 3.0)
		else:
			# Fade back to normal transparent
			filter.color.a = move_toward(filter.color.a, 0.0, _delta * 5.0)

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
