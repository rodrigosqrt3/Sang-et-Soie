extends Node2D

# This excursion is about recovering information, not clearing an arena.
var score: int = 0
var fragment_collected: bool = false
var detected_this_run: bool = false

const FRAGMENT_SPOTS: Array[Vector2] = [
	Vector2(110, 65),
	Vector2(360, 65),
	Vector2(650, 65)
]

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
@onready var list_fragment: Area2D = $ListFragment

func _ready() -> void:
	var fragment_index: int = randi_range(0, FRAGMENT_SPOTS.size() - 1)
	list_fragment.position = FRAGMENT_SPOTS[fragment_index]
	configure_guard_patrols()
	update_score_ui()

func configure_guard_patrols() -> void:
	assign_patrol($GuardWest, WEST_PATROL)
	assign_patrol($GuardGarden, GARDEN_PATROL)
	assign_patrol($GuardEast, EAST_PATROL)

func assign_patrol(guard: Node, route_points: Array[Vector2]) -> void:
	if guard.has_method("set_patrol_route"):
		guard.call("set_patrol_route", route_points)

# Defeating guards is optional and increases persistent consequences.
func add_score(amount: int) -> void:
	score += amount
	update_score_ui()

# Updates the text shown on screen
func update_score_ui() -> void:
	if fragment_collected:
		score_label.text = "FRAGMENT SECURED. RETURN TO THE GRATE.  |  Violence: " + str(score)
	else:
		score_label.text = "Find the stolen list fragment  |  Violence: " + str(score)

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
	if detected_this_run:
		return
	detected_this_run = true
	Global.exposure += 1
	update_score_ui()

func collect_list_fragment() -> void:
	if fragment_collected:
		return

	fragment_collected = true
	Global.has_list_fragment = true
	Global.fragment_recovered_without_killing = score == 0

	var spawner: Node = $EnemySpawner
	if spawner and spawner.has_method("begin_escape"):
		spawner.call("begin_escape")

	var escape_scene: PackedScene = load("res://escape_route.tscn") as PackedScene
	var escape_route: Area2D = escape_scene.instantiate() as Area2D
	escape_route.global_position = Vector2(80, 520)
	add_child(escape_route)
	update_score_ui()

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
		var concealed: bool = bool(player.call("is_concealed"))
		if concealed:
			stealth_tools_label.text = "COINS [Q]: " + str(coins) + "  |  HIDDEN"
			stealth_tools_label.modulate = Color(0.46, 0.82, 0.62)
		else:
			stealth_tools_label.text = "COINS [Q]: " + str(coins) + "  |  EXPOSED"
			stealth_tools_label.modulate = Color(0.72, 0.68, 0.58)
