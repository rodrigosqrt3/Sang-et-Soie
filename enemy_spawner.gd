extends Node2D

# Preload the enemy scene so we can create instances of it programmatically
const ENEMY_SCENE = preload("res://enemy.tscn")

# Reference to our Timer node
@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	# Programmatically connect the timer's timeout signal to our spawn function
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	# Start the timer to trigger every 4.0 seconds (adjust this to make the game harder!)
	spawn_timer.start(4.0)

func _on_spawn_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	# 1. Instantiate (create a clone of) the enemy scene in memory
	var enemy_instance = ENEMY_SCENE.instantiate() as CharacterBody2D
	
	# 2. Generate a random spawn position (math using random range in pixels)
	# This keeps enemies spawning inside a specific play area
	var spawn_x = randf_range(100.0, 700.0)
	var spawn_y = randf_range(100.0, 500.0)
	enemy_instance.global_position = Vector2(spawn_x, spawn_y)
	
	# 3. Add the newly created enemy to the World scene (our parent)
	get_parent().add_child(enemy_instance)
	
	print("New enemy spawned at: ", enemy_instance.global_position)