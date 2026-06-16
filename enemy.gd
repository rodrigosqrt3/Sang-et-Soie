extends CharacterBody2D

# Enemy stats
const MAX_HEALTH: int = 3
var current_health: int = MAX_HEALTH

# Movement speed (when chasing the player)
const SPEED: float = 120.0

# Knockback stats
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_DECAY: float = 15.0 # How fast the knockback slows down (friction)

# Color variables for the hit flash effect
const RED_COLOR = Color(0.6, 0.0, 0.0)
const FLASH_COLOR = Color.WHITE

# References to nodes
@onready var hurtbox: Area2D = $Hurtbox
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	# Programmatically connect the Hurtbox signal when an Area enters it
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(delta: float) -> void:
	# 1. If we have active knockback, apply it and decay it over time
	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		# Smoothly reduce the knockback velocity towards Vector2.ZERO using delta-time
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta * 150.0)
		move_and_slide()
		return
		
	# 2. Find the player using the global "player" group
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		
		# Calculate the direction vector pointing from the enemy to the player
		var direction = global_position.direction_to(player.global_position)
		
		# Move toward the player using built-in physics
		velocity = direction * SPEED
		move_and_slide()

# This function runs automatically whenever a physical area overlaps our Hurtbox
func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Check if the area that entered is the player's weapon (AttackArea)
	if area.name == "AttackArea":
		take_damage(1)

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Enemy took damage! Remaining HP: ", current_health)
	
	# Calculate Knockback: Vector from player position to enemy position (normalized)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		var knockback_direction = (global_position - player.global_position).normalized()
		# Instantly apply a massive velocity burst in the opposite direction
		knockback_velocity = knockback_direction * 1000.0
	
	# Visual feedback: Hit Flash (temporarily flash white)
	color_rect.color = FLASH_COLOR
	await get_tree().create_timer(0.08).timeout
	color_rect.color = RED_COLOR
	
	# Death check
	if current_health <= 0:
		die()

func die() -> void:
	print("Enemy defeated!")
	
	# Safely notify the parent (World) to add score before this node is deleted
	if get_parent().has_method("add_score"):
		get_parent().add_score(1)
		
	queue_free() # Destroys this enemy node completely from the game world
