extends Node2D

@export_enum("maintenance", "cistern") var sector_id: String = "maintenance"
@export var sector_title: String = "PARIS UNDERGROUND"
@export var room_size: Vector2i = Vector2i(1200, 700)

const MAINTENANCE_PATROL_A: Array[Vector2] = [
	Vector2(210, 170), Vector2(520, 170), Vector2(520, 330), Vector2(210, 330)
]
const MAINTENANCE_PATROL_B: Array[Vector2] = [
	Vector2(680, 520), Vector2(1030, 520), Vector2(1030, 260), Vector2(680, 260)
]
const CISTERN_PATROL_A: Array[Vector2] = [
	Vector2(180, 180), Vector2(530, 180), Vector2(530, 500), Vector2(180, 500)
]
const CISTERN_PATROL_B: Array[Vector2] = [
	Vector2(700, 180), Vector2(1040, 180), Vector2(1040, 500), Vector2(700, 500)
]

@onready var score_label: Label = $UI/ScoreLabel
@onready var dash_bar: ProgressBar = $UI/DashBar
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var focus_bar: ProgressBar = $UI/FocusBar
@onready var tools_label: Label = $UI/ToolsLabel
@onready var monocle_filter: ColorRect = $UI/MonocleFilter

func _ready() -> void:
	configure_guards()
	Global.position_player_at_pending_spawn(self)
	configure_camera_limits()
	score_label.text = sector_title

func configure_guards() -> void:
	if sector_id == "maintenance":
		assign_patrol(get_node_or_null("GuardMaintenanceA"), MAINTENANCE_PATROL_A)
		assign_patrol(get_node_or_null("GuardMaintenanceB"), MAINTENANCE_PATROL_B)
	else:
		assign_patrol(get_node_or_null("GuardCisternA"), CISTERN_PATROL_A)
		assign_patrol(get_node_or_null("GuardCisternB"), CISTERN_PATROL_B)

func assign_patrol(guard: Node, route_points: Array[Vector2]) -> void:
	if guard != null and guard.has_method("set_patrol_route"):
		guard.call("set_patrol_route", route_points)

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
	camera.limit_right = room_size.x
	camera.limit_bottom = room_size.y
	camera.limit_smoothed = true

func _process(delta: float) -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player: CharacterBody2D = players[0] as CharacterBody2D
	if player == null:
		return

	health_bar.value = player.current_health
	dash_bar.value = (Global.dash_cooldown - player.dash_cooldown_timer) / Global.dash_cooldown * 100.0
	focus_bar.value = player.current_focus
	tools_label.text = "COINS [Q]: " + str(player.distraction_charges) + "  |  LE REGARD [RMB]"
	if player.is_using_monocle:
		monocle_filter.color.a = move_toward(monocle_filter.color.a, 0.42, delta * 3.0)
	else:
		monocle_filter.color.a = move_toward(monocle_filter.color.a, 0.0, delta * 5.0)