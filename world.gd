extends Node2D

# Global score and victory condition
var score: int = 0
const CRATE_SCENE = preload("res://crate.tscn")
const CRATES_TO_SPAWN: int = 6 # Number of breakable crates to generate on startup
const KILLS_TO_WIN: int = 10

# Reference to the UI label
@onready var score_label: Label = $UI/ScoreLabel
@onready var dash_bar: ProgressBar = $UI/DashBar

func _ready() -> void:
	update_score_ui()
	# Procedurally generate crates at the start of the level
	spawn_initial_crates()

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
	# Find the player to read their current dash cooldown
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		
		# Mathematical percentage calculation: (TotalTime - RemainingTime) / TotalTime * 100
		var cooldown_percentage = (player.DASH_COOLDOWN_TIME - player.dash_cooldown_timer) / player.DASH_COOLDOWN_TIME * 100.0
		dash_bar.value = cooldown_percentage

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
