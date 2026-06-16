extends CharacterBody2D

# Exported variable to toggle peace/combat mode in the Inspector
@export var is_safe_mode: bool = false

# Movement stats
const SPEED: float = 300.0
const DASH_SPEED: float = 1200.0
const DASH_DURATION: float = 0.15

# Player health stats
const MAX_HEALTH: int = 3
var current_health: int = MAX_HEALTH

# Color variables for visual feedback
const EMERALD_GREEN = Color(0.14, 0.45, 0.23)
const DAMAGE_COLOR = Color.RED

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
	attack_area.visible = false
	attack_area.monitorable = false
	attack_area.monitoring = false
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(_delta: float) -> void:
	if is_dashing:
		move_and_slide()
		return
		
	# Standard 8-way movement (always enabled)
	var direction := Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	
	# ONLY allow dashing and attacking if we are NOT in Safe Mode!
	if not is_safe_mode:
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
	
	# Spawn three ghosts at short intervals (0.05 seconds) during the 0.15s dash
	spawn_ghost_effect()
	await get_tree().create_timer(0.05).timeout
	spawn_ghost_effect()
	await get_tree().create_timer(0.05).timeout
	spawn_ghost_effect()
	
	# Wait the final remaining 0.05s of the dash
	await get_tree().create_timer(0.05).timeout
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
	# CHANGE: Instead of reloading the current scene, we load the safe Hub!
	get_tree().change_scene_to_file("res://bal_des_victimes.tscn")

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

# Spawns a temporary, fading ghost effect at the player's current position
func spawn_ghost_effect() -> void:
	# Create a temporary ColorRect programmatically
	var ghost = ColorRect.new()
	ghost.size = color_rect.size
	# Center it at the player's exact global position
	ghost.global_position = global_position - (color_rect.size / 2.0)
	# Give it a semi-transparent emerald green color (Alpha = 0.4)
	ghost.color = Color(0.14, 0.45, 0.23, 0.4)
	
	# Add the ghost to the World scene so it stays fixed on the ground while we move
	get_parent().add_child(ghost)
	
	# Create a beautiful Tween to animate the opacity fadeout
	var tween = create_tween()
	# Smoothly reduce the alpha channel of the color to 0.0 over 0.25 seconds
	tween.tween_property(ghost, "color:a", 0.0, 0.25)
	# Automatically delete the ghost node from memory when the animation finishes!
	tween.tween_callback(ghost.queue_free)
