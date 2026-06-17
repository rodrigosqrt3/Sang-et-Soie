extends CharacterBody2D

# Boss Stats
const MAX_HEALTH: int = 5
var current_health: int = MAX_HEALTH

const SPEED: float = 70.0          # Relentless but slow
const STOP_DISTANCE: float = 300.0  # Safe shooting range

# Preload the projectile and the secret dossier
const PROJECTILE_SCENE = preload("res://projectile.tscn")
const DOSSIER_SCENE = preload("res://dossier.tscn")

# Knockback stats
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_DECAY: float = 15.0

# Colors for hit flash (using deep purple as default)
const PURPLE_COLOR = Color(0.55, 0.27, 0.68)
const FLASH_COLOR = Color.WHITE

# References to nodes
@onready var hurtbox: Area2D = $Hurtbox
@onready var color_rect: ColorRect = $ColorRect
@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	current_health = MAX_HEALTH
	color_rect.color = PURPLE_COLOR
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
	# Connect and start the fast shooting timer
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start(1.2) # Shoots much faster! Every 1.2 seconds

func _physics_process(delta: float) -> void:
	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta * 150.0)
		move_and_slide()
		return
		
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		var distance = global_position.distance_to(player.global_position)
		var direction = global_position.direction_to(player.global_position)
		
		if distance > STOP_DISTANCE:
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO
			
		move_and_slide()

func _on_shoot_timer_timeout() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and knockback_velocity.length() <= 10.0:
		var player = players[0] as CharacterBody2D
		var distance = global_position.distance_to(player.global_position)
		if distance <= STOP_DISTANCE + 150.0:
			shoot_at_player(player)

func shoot_at_player(player: CharacterBody2D) -> void:
	var proj = PROJECTILE_SCENE.instantiate() as Area2D
	var dir = global_position.direction_to(player.global_position)
	proj.global_position = global_position + (dir * 35.0) # Spawn offset matches bigger boss size
	proj.direction = dir
	get_parent().add_child(proj)
	print("The Captain shot a heavy projectile!")

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		take_damage(1)

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Boss took damage! Remaining HP: ", current_health)
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		if player.has_method("freeze_frame"):
			player.freeze_frame(0.08)
		if player.has_method("shake_camera"):
			player.shake_camera(8.0, 6.0)
			
		var knockback_direction = (global_position - player.global_position).normalized()
		knockback_velocity = knockback_direction * 800.0 # Heavy knockback resistance
		
	color_rect.color = FLASH_COLOR
	await get_tree().create_timer(0.08).timeout
	color_rect.color = PURPLE_COLOR
	
	if current_health <= 0:
		die()

func die() -> void:
	print("The Captain has been defeated!")
	
	# Spawn the secret dossier exactly where the boss died!
	var dossier_instance = DOSSIER_SCENE.instantiate() as Area2D
	dossier_instance.global_position = global_position
	get_parent().call_deferred("add_child", dossier_instance)
	
	color_rect.visible = false
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)
	queue_free()