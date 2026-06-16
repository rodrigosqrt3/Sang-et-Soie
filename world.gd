extends Node2D

# Global score and victory condition
var score: int = 0
const KILLS_TO_WIN: int = 10

# Reference to the UI label
@onready var score_label: Label = $UI/ScoreLabel

func _ready() -> void:
	update_score_ui()

# Function called by enemies when they die
func add_score(amount: int) -> void:
	score += amount
	update_score_ui()
	
	# Check if the victory condition is met
	if score >= KILLS_TO_WIN:
		chamber_cleared()

# Updates the text shown on screen
func update_score_ui() -> void:
	score_label.text = "Kills: " + str(score) + " / " + str(KILLS_TO_WIN)

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