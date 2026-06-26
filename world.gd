extends Node2D

# Global score and victory condition
var score: int = 0
const CRATE_SCENE = preload("res://crate.tscn")
const CRATES_TO_SPAWN: int = 6 # Number of breakable crates to generate on startup
const TRAP_SCENE = preload("res://spike_trap.tscn")
const TRAPS_TO_SPAWN: int = 4 # Number of floor traps to generate on startup
const KILLS_TO_WIN: int = 10

# Reference to the UI label
@onready var score_label: Label = $UI/ScoreLabel
@onready var dash_bar: ProgressBar = $UI/DashBar
@onready var health_bar: ProgressBar = $UI/HealthBar

func _ready() -> void:
	update_score_ui()
	spawn_initial_crates()
	spawn_initial_traps()

# Function called by enemies when they die
func add_score(amount: int) -> void:
	score += amount
	
	# ADD: Add 1 Franc to the persistent global wallet for every kill!
	Global.francs += amount
	
	update_score_ui()
	
	if score >= KILLS_TO_WIN:
		chamber_cleared()

# Updates the text shown on screen
func update_score_ui() -> void:
	score_label.text = "Kills: " + str(score) + " / " + str(KILLS_TO_WIN) + "  |  Francs: " + str(Global.francs)

# Triggers the victory sequence when the chamber is cleared
func chamber_cleared() -> void:
	print("Victory! Chamber cleared.")
	
	# 1. Stop the enemy spawner timer so no new enemies appear
	var spawner = $EnemySpawner
	if spawner and spawner.has_node("SpawnTimer"):
		spawner.get_node("SpawnTimer").stop()
		
	# 2. Safely destroy all remaining enemies currently active on screen
	var active_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
			
	# 3. Instantiate and spawn the Escape Route in the center of the screen
	var escape_route = load("res://escape_route.tscn").instantiate() as Area2D
	escape_route.global_position = Vector2(400, 300) # Middle of the screen
	add_child(escape_route)
	
	# 4. Update the UI text to celebrate the victory!
	score_label.text = "CHAMBER CLEARED! ESCAPE THROUGH THE GRATE"

func _process(_delta: float) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		
		# Update standard HUD
		health_bar.value = player.current_health
		dash_bar.value = (player.DASH_COOLDOWN_TIME - player.dash_cooldown_timer) / player.DASH_COOLDOWN_TIME * 100.0
		
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

# Generates and places breakable crates at random coordinates on startup
func spawn_initial_crates() -> void:
	for i in range(CRATES_TO_SPAWN):
		var crate_instance = CRATE_SCENE.instantiate() as StaticBody2D
		
		# Randomize coordinates within the playable bounds of our scene
		var spawn_x = randf_range(150.0, 650.0)
		var spawn_y = randf_range(150.0, 450.0)
		crate_instance.global_position = Vector2(spawn_x, spawn_y)
		
		# Add the crate to the world
		add_child(crate_instance)
		print("Crate procedurally spawned at: ", crate_instance.global_position)

# Generates and places spike traps at random coordinates on startup
func spawn_initial_traps() -> void:
	for i in range(TRAPS_TO_SPAWN):
		var trap_instance = TRAP_SCENE.instantiate() as Area2D
		
		# Randomize coordinates within the playable bounds of our scene
		var spawn_x = randf_range(150.0, 650.0)
		var spawn_y = randf_range(150.0, 450.0)
		trap_instance.global_position = Vector2(spawn_x, spawn_y)
		
		# Add the trap to the world
		add_child(trap_instance)
		print("Spike trap procedurally spawned at: ", trap_instance.global_position)
