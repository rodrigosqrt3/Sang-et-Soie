extends Node2D

# Preload all three enemy types and the spawn warning
const ENEMY_SCENE = preload("res://enemy.tscn")
const FAST_ENEMY_SCENE = preload("res://fast_enemy.tscn")
const RANGED_ENEMY_SCENE = preload("res://ranged_enemy.tscn")
const WARNING_SCENE = preload("res://spawn_warning.tscn")

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start(4.0)

func _on_spawn_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy() -> void:
	var spawn_x = randf_range(100.0, 700.0)
	var spawn_y = randf_range(100.0, 500.0)
	var spawn_position = Vector2(spawn_x, spawn_y)
	
	var warning_instance = WARNING_SCENE.instantiate() as Node2D
	warning_instance.global_position = spawn_position
	get_parent().add_child(warning_instance)
	
	await get_tree().create_timer(1.2).timeout
	
	if is_instance_valid(warning_instance):
		warning_instance.queue_free()
	
	# Determine which enemy type to spawn (50% Normal, 25% Fast, 25% Ranged)
	var enemy_instance: CharacterBody2D
	var roll = randf()
	
	if roll < 0.25:
		enemy_instance = FAST_ENEMY_SCENE.instantiate() as CharacterBody2D
	elif roll < 0.50:
		enemy_instance = RANGED_ENEMY_SCENE.instantiate() as CharacterBody2D
	else:
		enemy_instance = ENEMY_SCENE.instantiate() as CharacterBody2D
		
	enemy_instance.global_position = spawn_position
	get_parent().add_child(enemy_instance)
	
	print("New enemy spawned: ", enemy_instance.name, " at ", enemy_instance.global_position)