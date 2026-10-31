extends CharacterBody2D
class_name CaptainBoss

# Boss Stats
const MAX_HEALTH: int = 7
var current_health: int = MAX_HEALTH
var phase: int = 1
var is_dead: bool = false

var move_speed: float = 65.0
var stop_distance: float = 300.0

# Preload the projectile and the secret dossier
const PROJECTILE_SCENE: PackedScene = preload("res://actors/enemies/projectile.tscn")
const DOSSIER_SCENE: PackedScene = preload("res://levels/underground/dossier.tscn")

# Knockback stats
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_DECAY: float = 15.0

# Mâchefer's rage, phase by phase: a tint laid over the paper figure.
const PHASE_TINTS: Array[Color] = [Color(0, 0, 0), Color(0.85, 0.15, 0.12), Color(1.0, 0.55, 0.2)]
const PHASE_TINT_AMOUNT: Array[float] = [0.0, 0.25, 0.4]
const FLASH_COLOR = Color.WHITE

var figure: PaperFigure

# References to nodes
@onready var hurtbox: Area2D = $Hurtbox
@onready var color_rect: ColorRect = $ColorRect
@onready var shoot_timer: Timer = $ShootTimer
@onready var bark_label: Label = $BarkLabel

func _ready() -> void:
	add_to_group("boss")
	collision_layer = 1
	collision_mask = 1
	current_health = MAX_HEALTH
	color_rect.visible = false
	figure = PaperFigure.new()
	figure.look = CharacterData.get_look("machefer")
	figure.seed_id = 1793
	figure.scale = Vector2(1.35, 1.35)
	add_child(figure)
	move_child(figure, color_rect.get_index() + 1)
	bark_label.visible = false
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

	# Connect and start the fast shooting timer
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start(1.7)
	announce("That name belongs to the dead.")

func restore_phase_tint() -> void:
	figure.set_flash(PHASE_TINTS[phase - 1], PHASE_TINT_AMOUNT[phase - 1])

func _physics_process(delta: float) -> void:
	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta * 150.0)
		move_and_slide()
		return
		
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player: CharacterBody2D = players[0] as CharacterBody2D
		var distance: float = global_position.distance_to(player.global_position)
		var direction: Vector2 = global_position.direction_to(player.global_position)
		figure.face_toward(direction)
		figure.moving_ratio = 0.6 if distance > stop_distance else 0.0

		if distance > stop_distance:
			velocity = direction * move_speed
		else:
			velocity = Vector2.ZERO
			
		move_and_slide()

func _on_shoot_timer_timeout() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and knockback_velocity.length() <= 10.0:
		var player: CharacterBody2D = players[0] as CharacterBody2D
		var distance: float = global_position.distance_to(player.global_position)
		if distance <= 480.0:
			shoot_at_player(player)

func shoot_at_player(player: CharacterBody2D) -> void:
	var base_direction: Vector2 = global_position.direction_to(player.global_position)
	spawn_projectile(base_direction)

	if phase >= 2:
		spawn_projectile(base_direction.rotated(-0.18))
		spawn_projectile(base_direction.rotated(0.18))

	if phase == 3:
		spawn_projectile(base_direction.rotated(-0.38))
		spawn_projectile(base_direction.rotated(0.38))

func spawn_projectile(direction: Vector2) -> void:
	var projectile_node: Node = PROJECTILE_SCENE.instantiate()
	if not projectile_node is Node2D:
		push_error("The projectile scene must have a Node2D-compatible root.")
		projectile_node.queue_free()
		return

	var projectile: Node2D = projectile_node as Node2D
	projectile.position = position + direction * 35.0
	projectile.set("direction", direction)
	get_parent().add_child(projectile)

func announce(text: String) -> void:
	bark_label.text = text
	bark_label.visible = true
	await get_tree().create_timer(1.6).timeout
	if is_instance_valid(bark_label):
		bark_label.visible = false

func enter_phase(new_phase: int) -> void:
	phase = new_phase
	if phase == 2:
		move_speed = 82.0
		stop_distance = 240.0
		shoot_timer.start(1.05)
		announce("He was lighter than he looked, your father. So are you.")
	elif phase == 3:
		move_speed = 115.0
		stop_distance = 170.0
		shoot_timer.start(0.72)
		announce("Come closer. Let me see which brother survived.")
	restore_phase_tint()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		take_damage(1)

func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_health -= amount
	print("Boss took damage! Remaining HP: ", current_health)

	if current_health <= 2 and phase < 3:
		enter_phase(3)
	elif current_health <= 4 and phase < 2:
		enter_phase(2)
	
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player: CharacterBody2D = players[0] as CharacterBody2D
		if player.has_method("freeze_frame"):
			player.freeze_frame(0.08)
		if player.has_method("shake_camera"):
			player.shake_camera(8.0, 6.0)
			
		var knockback_direction: Vector2 = (global_position - player.global_position).normalized()
		knockback_velocity = knockback_direction * 650.0
		
	figure.set_flash(FLASH_COLOR, 0.9)
	await get_tree().create_timer(0.08).timeout
	restore_phase_tint()

	if current_health <= 0:
		die()

func die() -> void:
	if is_dead:
		return

	is_dead = true
	shoot_timer.stop()
	print("The Captain has been defeated!")
	
	# Spawn the secret dossier exactly where the boss died!
	var dossier_node: Node = DOSSIER_SCENE.instantiate()
	if dossier_node is Node2D:
		var dossier_instance: Node2D = dossier_node as Node2D
		dossier_instance.position = position
		get_parent().call_deferred("add_child", dossier_instance)
	else:
		push_error("The dossier scene must have a Node2D-compatible root.")
		dossier_node.queue_free()
	
	color_rect.visible = false
	figure.visible = false
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)
	queue_free()