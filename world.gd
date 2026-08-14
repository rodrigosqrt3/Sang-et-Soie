extends Node2D

# This excursion is about recovering information, not clearing an arena.
var score: int = 0
var fragment_collected: bool = false

const FRAGMENT_SPOTS: Array[Vector2] = [
	Vector2(110, 65),
	Vector2(360, 65),
	Vector2(650, 65)
]

# Reference to the UI label
@onready var score_label: Label = $UI/ScoreLabel
@onready var dash_bar: ProgressBar = $UI/DashBar
@onready var health_bar: ProgressBar = $UI/HealthBar
@onready var approach_label: Label = $UI/ApproachLabel
@onready var list_fragment: Area2D = $ListFragment

func _ready() -> void:
	var fragment_index: int = randi_range(0, FRAGMENT_SPOTS.size() - 1)
	list_fragment.position = FRAGMENT_SPOTS[fragment_index]
	update_score_ui()

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

	if score == 0:
		approach_label.text = "METHOD: DISCREET  |  Exposure: " + str(Global.exposure)
		approach_label.modulate = Color(0.82, 0.72, 0.48)
	else:
		approach_label.text = "METHOD: VIOLENT  |  Exposure: " + str(Global.exposure)
		approach_label.modulate = Color(0.88, 0.32, 0.28)

func collect_list_fragment() -> void:
	if fragment_collected:
		return

	fragment_collected = true
	Global.has_list_fragment = true
	Global.fragment_recovered_without_killing = score == 0

	var spawner = $EnemySpawner
	if spawner and spawner.has_method("begin_escape"):
		spawner.call("begin_escape")

	var escape_route = load("res://escape_route.tscn").instantiate() as Area2D
	escape_route.global_position = Vector2(80, 520)
	add_child(escape_route)
	update_score_ui()

func _process(_delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		
		# Update standard HUD
		health_bar.value = player.current_health
		dash_bar.value = (Global.dash_cooldown - player.dash_cooldown_timer) / Global.dash_cooldown * 100.0
		
		# Update Focus Bar
		var focus_bar = $UI/FocusBar
		focus_bar.value = player.current_focus
		
		# Fade the dark screen filter in and out based on Monocle usage
		var filter = $UI/MonocleFilter
		if player.is_using_monocle:
			# Lerp smoothly darkens the screen with a purple/blue tint
			filter.color.a = move_toward(filter.color.a, 0.4, _delta * 3.0)
		else:
			# Fade back to normal transparent
			filter.color.a = move_toward(filter.color.a, 0.0, _delta * 5.0)
