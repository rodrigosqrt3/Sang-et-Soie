extends CharacterBody2D

# Stats
const MAX_HEALTH: int = 3
var current_health: int = MAX_HEALTH

const SPEED: float = 80.0          # Slower than normal melee enemy
const STOP_DISTANCE: float = 280.0  # Distance where the enemy stops and shoots

# Preload the projectile scene so we can spawn it
const PROJECTILE_SCENE = preload("res://projectile.tscn")

# Knockback stats
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_DECAY: float = 15.0

# Colors for hit flash (using navy blue as default)
const NAVY_BLUE = Color(0.16, 0.50, 0.72)
const FLASH_COLOR = Color.WHITE

# References to nodes
@onready var hurtbox: Area2D = $Hurtbox
@onready var color_rect: ColorRect = $ColorRect
@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	add_to_group("enemies")
	current_health = MAX_HEALTH
	color_rect.color = NAVY_BLUE
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
	# Connect the shoot timer signal
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start(2.0) # Shoot every 2.0 seconds

func _physics_process(delta: float) -> void:
	# 1. If we have active knockback, apply it and decay it
	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta * 150.0)
		move_and_slide()
		return
		
	# 2. Find the player using the global "player" group
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		var distance = global_position.distance_to(player.global_position)
		var direction = global_position.direction_to(player.global_position)
		
		# If too far, walk towards the player. If close enough, stop to shoot!
		if distance > STOP_DISTANCE:
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO
			
		move_and_slide()

func _on_shoot_timer_timeout() -> void:
	# Only shoot if the player is alive and not during knockback recovery
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and knockback_velocity.length() <= 10.0:
		var player = players[0] as CharacterBody2D
		var distance = global_position.distance_to(player.global_position)
		
		# Only shoot if the player is within range
		if distance <= STOP_DISTANCE + 100.0:
			shoot_at_player(player)

func shoot_at_player(player: CharacterBody2D) -> void:
	var proj = PROJECTILE_SCENE.instantiate() as Area2D
	
	# Calculate direction and spawn projectile slightly in front of the enemy
	var dir = global_position.direction_to(player.global_position)
	proj.global_position = global_position + (dir * 25.0)
	proj.direction = dir
	
	# Add the projectile to the World scene
	get_parent().add_child(proj)
	print("Ranged enemy shot a projectile!")

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		take_damage(1)

func take_damage(amount: int) -> void:
	current_health -= amount
	print(name, " took damage! Remaining HP: ", current_health)
	
	# Trigger hit freeze and camera shake
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		if player.has_method("freeze_frame"):
			player.freeze_frame(0.08)
		if player.has_method("shake_camera"):
			player.shake_camera(8.0, 6.0)
			
		var knockback_direction = (global_position - player.global_position).normalized()
		knockback_velocity = knockback_direction * 1000.0
		
	color_rect.color = FLASH_COLOR
	await get_tree().create_timer(0.08).timeout
	color_rect.color = NAVY_BLUE
	
	if current_health <= 0:
		die()

func die() -> void:
	print(name, " defeated!")
	if get_parent().has_method("add_score"):
		get_parent().add_score(1)
	color_rect.visible = false
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)
	queue_free()
