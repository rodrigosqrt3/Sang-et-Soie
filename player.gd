extends CharacterBody2D

# Movement stats
const SPEED: float = 300.0
const DASH_SPEED: float = 1200.0
const DASH_DURATION: float = 0.15

# Player health stats
const MAX_HEALTH: int = 3
var current_health: int = MAX_HEALTH

# Color variables for visual feedback
const EMERALD_GREEN = Color(0.14, 0.45, 0.23) # Emerald green (approx. #24733b)
const DAMAGE_COLOR = Color.RED                 # Red flash on hit

# State variables
var is_dashing: bool = false
var is_attacking: bool = false

# References to nodes
@onready var attack_pivot: Node2D = $AttackPivot
@onready var attack_area: Area2D = $AttackPivot/AttackArea
@onready var hurtbox: Area2D = $Hurtbox
@onready var color_rect: ColorRect = $ColorRect
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	# Hide and disable the attack hitbox at start
	attack_area.visible = false
	attack_area.monitorable = false
	attack_area.monitoring = false
	
	# Connect the player's Hurtbox signal to detect incoming enemy attacks
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(_delta: float) -> void:
	# If dashing, bypass normal movement and attack inputs
	if is_dashing:
		move_and_slide()
		return
		
	# Standard 8-way movement
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	
	# Trigger Dash (Spacebar)
	if Input.is_action_just_pressed("dash") and direction != Vector2.ZERO:
		start_dash(direction)
		
	# Trigger Attack (Left Mouse Button)
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()
		
	move_and_slide()

func start_dash(dash_direction: Vector2) -> void:
	is_dashing = true
	velocity = dash_direction * DASH_SPEED
	await get_tree().create_timer(DASH_DURATION).timeout
	is_dashing = false

func start_attack() -> void:
	is_attacking = true
	var mouse_position := get_global_mouse_position()
	attack_pivot.look_at(mouse_position)
	attack_area.visible = true
	attack_area.monitorable = true
	attack_area.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack_area.visible = false
	attack_area.monitorable = false
	attack_area.monitoring = false
	is_attacking = false

# This function runs automatically when an Area enters the Player's Hurtbox
func _on_hurtbox_area_entered(area: Area2D) -> void:
	# If the area that hit us is the enemy's damage area (Hitbox)
	if area.name == "Hitbox":
		take_damage(1)

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Player hit! Remaining HP: ", current_health)
	camera.apply_shake(18.0, 4.0)
	
	# Visual feedback: Flash Red when taking damage
	color_rect.color = DAMAGE_COLOR
	await get_tree().create_timer(0.1).timeout
	color_rect.color = EMERALD_GREEN
	
	# Death check
	if current_health <= 0:
		die()

func die() -> void:
	print("Player died! Returning to the start of the loop...")
	# Reloads the current scene to simulate the "death loop" resetting
	get_tree().reload_current_scene()

# Public function for other nodes (like enemies) to trigger camera shake
func shake_camera(strength: float, decay: float = 5.0) -> void:
	camera.apply_shake(strength, decay)

# Public function to freeze the frame momentarily (Hit-Stop)
func freeze_frame(duration: float, time_scale: float = 0.0) -> void:
	Engine.time_scale = time_scale
	
	# Create a timer that ignores the time_scale so it can finish in real-world time
	await get_tree().create_timer(duration, true, false, true).timeout
	
	Engine.time_scale = 1.0

# Public function to heal the player (Anesthesia)
func heal(amount: int) -> void:
	# Only heal if the player is currently injured
	if current_health < MAX_HEALTH:
		current_health = clamp(current_health + amount, 0, MAX_HEALTH)
		print("Étienne drank champagne. Decadence restored. Remaining HP: ", current_health)
		
		# Visual feedback: Flash Gold when healing
		color_rect.color = Color(0.8, 0.6, 0.0) # Gold flash
		await get_tree().create_timer(0.1).timeout
		color_rect.color = EMERALD_GREEN