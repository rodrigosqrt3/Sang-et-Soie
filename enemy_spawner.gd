extends Node2D

# Preload all three enemy types and the spawn warning
const ENEMY_SCENE = preload("res://enemy.tscn")
const FAST_ENEMY_SCENE = preload("res://fast_enemy.tscn")
const RANGED_ENEMY_SCENE = preload("res://ranged_enemy.tscn")
const WARNING_SCENE = preload("res://spawn_warning.tscn")

@onready var spawn_timer: Timer = $SpawnTimer

var escape_mode: bool = false
const NORMAL_MAX_ENEMIES: int = 4
const ESCAPE_MAX_ENEMIES: int = 7
const NORMAL_SPAWN_POINTS: Array[Vector2] = [
	Vector2(80, 160),
	Vector2(720, 160),
	Vector2(720, 520),
	Vector2(400, 500)
]
const ESCAPE_SPAWN_POINTS: Array[Vector2] = [
	Vector2(80, 520),
	Vector2(720, 520),
	Vector2(400, 155)
]

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	# Give the player time to read the room before pressure begins. Exposure from
	# earlier choices shortens that grace period without removing it entirely.
	var opening_interval: float = clampf(5.5 - float(Global.exposure) * 0.15, 3.2, 5.5)
	spawn_timer.start(opening_interval)

func _on_spawn_timer_timeout() -> void:
	var enemy_limit: int = ESCAPE_MAX_ENEMIES if escape_mode else NORMAL_MAX_ENEMIES
	if get_tree().get_nodes_in_group("enemies").size() < enemy_limit:
		spawn_enemy()

func begin_escape() -> void:
	if escape_mode:
		return

	escape_mode = true
	spawn_timer.start(1.8)
	# The first reinforcement makes the change of phase immediate and readable.
	spawn_enemy()

func choose_spawn_position() -> Vector2:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	var player_position: Vector2 = Vector2(400, 300)
	if players.size() > 0:
		var player: Node2D = players[0] as Node2D
		player_position = player.global_position

	var minimum_distance: float = 150.0 if escape_mode else 230.0
	var points: Array[Vector2] = ESCAPE_SPAWN_POINTS if escape_mode else NORMAL_SPAWN_POINTS
	var start_index: int = randi_range(0, points.size() - 1)
	var candidate: Vector2 = points[start_index]
	for offset in range(points.size()):
		var point_index: int = (start_index + offset) % points.size()
		candidate = points[point_index]
		if candidate.distance_to(player_position) >= minimum_distance:
			break
	return candidate

func spawn_enemy() -> void:
	var spawn_position: Vector2 = choose_spawn_position()
	
	var warning_instance: Node2D = WARNING_SCENE.instantiate() as Node2D
	warning_instance.global_position = spawn_position
	get_parent().add_child(warning_instance)
	
	await get_tree().create_timer(1.2).timeout
	
	if is_instance_valid(warning_instance):
		warning_instance.queue_free()
	
	# The return journey favors faster enemies, changing the texture of the run.
	var enemy_instance: CharacterBody2D
	var roll: float = randf()
	
	if escape_mode and roll < 0.45:
		enemy_instance = FAST_ENEMY_SCENE.instantiate() as CharacterBody2D
	elif escape_mode and roll < 0.70:
		enemy_instance = RANGED_ENEMY_SCENE.instantiate() as CharacterBody2D
	elif roll < 0.20:
		enemy_instance = FAST_ENEMY_SCENE.instantiate() as CharacterBody2D
	elif roll < 0.40:
		enemy_instance = RANGED_ENEMY_SCENE.instantiate() as CharacterBody2D
	else:
		enemy_instance = ENEMY_SCENE.instantiate() as CharacterBody2D
		
	enemy_instance.global_position = spawn_position
	get_parent().add_child(enemy_instance)
	
	print("New enemy spawned: ", enemy_instance.name, " at ", enemy_instance.global_position)