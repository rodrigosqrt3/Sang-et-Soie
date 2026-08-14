extends Node2D

# Preload all three enemy types and the spawn warning
const ENEMY_SCENE: PackedScene = preload("res://enemy.tscn")
const FAST_ENEMY_SCENE: PackedScene = preload("res://fast_enemy.tscn")
const RANGED_ENEMY_SCENE: PackedScene = preload("res://ranged_enemy.tscn")
const WARNING_SCENE: PackedScene = preload("res://spawn_warning.tscn")

@onready var spawn_timer: Timer = $SpawnTimer

var escape_mode: bool = false
const ESCAPE_MAX_ENEMIES: int = 7
const ESCAPE_SPAWN_POINTS: Array[Vector2] = [
	Vector2(80, 520),
	Vector2(720, 520),
	Vector2(400, 155)
]

func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	# The infiltration begins with a finite, readable guard arrangement. The city
	# sends reinforcements only after the list fragment has been taken.
	spawn_timer.stop()

func _on_spawn_timer_timeout() -> void:
	if not escape_mode:
		return
	if get_tree().get_nodes_in_group("enemies").size() < ESCAPE_MAX_ENEMIES:
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

	var minimum_distance: float = 150.0
	var start_index: int = randi_range(0, ESCAPE_SPAWN_POINTS.size() - 1)
	var candidate: Vector2 = ESCAPE_SPAWN_POINTS[start_index]
	for point_offset in range(ESCAPE_SPAWN_POINTS.size()):
		var point_index: int = (start_index + point_offset) % ESCAPE_SPAWN_POINTS.size()
		candidate = ESCAPE_SPAWN_POINTS[point_index]
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
	
	if roll < 0.45:
		enemy_instance = FAST_ENEMY_SCENE.instantiate() as CharacterBody2D
	elif roll < 0.70:
		enemy_instance = RANGED_ENEMY_SCENE.instantiate() as CharacterBody2D
	else:
		enemy_instance = ENEMY_SCENE.instantiate() as CharacterBody2D
		
	enemy_instance.global_position = spawn_position
	get_parent().add_child(enemy_instance)
	var center_direction: Vector2 = spawn_position.direction_to(Vector2(400, 300))
	if enemy_instance.has_method("set_patrol_direction"):
		enemy_instance.call("set_patrol_direction", center_direction)
	
	print("New enemy spawned: ", enemy_instance.name, " at ", enemy_instance.global_position)