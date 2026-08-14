extends Node2D

@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var dash_bar: ProgressBar = $UI/DashBar
@onready var score_label: Label = $UI/ScoreLabel
@onready var boss_health_bar: ProgressBar = $UI/BossHealthBar
@onready var boss_label: Label = $UI/BossLabel

func _ready() -> void:
	score_label.text = "THE CAPTAIN HOLDS THE COURIER'S LEDGER"
	Global.position_player_at_pending_spawn(self)

func _process(_delta: float) -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player: CharacterBody2D = players[0] as CharacterBody2D
		
		# Update HUD
		health_bar.value = player.current_health
		
		var cooldown_pct: float = (Global.dash_cooldown - player.dash_cooldown_timer) / Global.dash_cooldown * 100.0
		dash_bar.value = cooldown_pct

	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	if bosses.size() > 0:
		var boss: CaptainBoss = bosses[0] as CaptainBoss
		boss_health_bar.visible = true
		boss_health_bar.value = boss.current_health
		boss_label.text = "THE CAPTAIN  |  PHASE " + str(boss.phase)
	else:
		boss_health_bar.visible = false
		boss_label.text = "THE LEDGER IS EXPOSED"