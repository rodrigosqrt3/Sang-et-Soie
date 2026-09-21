extends Node2D

@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var dash_bar: ProgressBar = $UI/DashBar
@onready var score_label: Label = $UI/ScoreLabel
@onready var boss_health_bar: ProgressBar = $UI/BossHealthBar
@onready var boss_label: Label = $UI/BossLabel
@onready var focus_bar: ProgressBar = $UI/FocusBar
@onready var tools_label: Label = $UI/ToolsLabel
@onready var monocle_filter: ColorRect = $UI/MonocleFilter

func _ready() -> void:
	score_label.text = "THE CAPTAIN HOLDS THE COURIER'S LEDGER"
	Global.position_player_at_pending_spawn(self)
	configure_camera_limits()

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

func _process(_delta: float) -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player: CharacterBody2D = players[0] as CharacterBody2D
		
		# Update HUD
		health_bar.value = player.current_health
		
		var cooldown_pct: float = (Global.dash_cooldown - player.dash_cooldown_timer) / Global.dash_cooldown * 100.0
		dash_bar.value = cooldown_pct
		focus_bar.value = player.current_focus
		tools_label.text = "COINS [Q]: " + str(player.distraction_charges) + "  |  LE REGARD [RMB]"
		if player.is_using_monocle:
			monocle_filter.color.a = move_toward(monocle_filter.color.a, 0.42, _delta * 3.0)
		else:
			monocle_filter.color.a = move_toward(monocle_filter.color.a, 0.0, _delta * 5.0)

	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	if bosses.size() > 0:
		var boss: CaptainBoss = bosses[0] as CaptainBoss
		boss_health_bar.visible = true
		boss_health_bar.value = boss.current_health
		boss_label.text = "THE CAPTAIN  |  PHASE " + str(boss.phase)
	else:
		boss_health_bar.visible = false
		boss_label.text = "THE LEDGER IS EXPOSED"