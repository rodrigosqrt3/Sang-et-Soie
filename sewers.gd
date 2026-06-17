extends Node2D

@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var dash_bar: ProgressBar = $UI/DashBar
@onready var score_label: Label = $UI/ScoreLabel

func _ready() -> void:
	# Inform the player of the final boss fight objective!
	score_label.text = "CHAMBER CLIMAX: DEFEAT THE CAPTAIN"

func _process(_delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		
		# Update HUD
		health_bar.value = player.current_health
		
		var cooldown_pct = (player.DASH_COOLDOWN_TIME - player.dash_cooldown_timer) / player.DASH_COOLDOWN_TIME * 100.0
		dash_bar.value = cooldown_pct