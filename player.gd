extends CharacterBody2D

# Exported variable to toggle peace/combat mode in the Inspector
@export var is_safe_mode: bool = false

# Movement stats
const SPEED: float = 300.0
const DASH_SPEED: float = 1200.0
const DASH_DURATION: float = 0.15
const DISTRACTION_SCENE: PackedScene = preload("res://distraction.tscn")
const MAX_DISTRACTION_CHARGES: int = 3
const DISTRACTION_RANGE: float = 250.0

# Player health stats
const MAX_HEALTH: int = 3
var current_health: int = MAX_HEALTH
const DASH_COOLDOWN_TIME: float = 1.0
var dash_cooldown_timer: float = 0.0

# Focus System (The "Mana" for Le Regard)
const MAX_FOCUS: float = 100.0
var current_focus: float = MAX_FOCUS
var is_using_monocle: bool = false

# Color variables for visual feedback
const EMERALD_GREEN = Color(0.14, 0.45, 0.23)
const DAMAGE_COLOR = Color.RED

# State variables
var is_dashing: bool = false
var is_attacking: bool = false
var is_dead: bool = false
var is_invulnerable: bool = false
var distraction_charges: int = MAX_DISTRACTION_CHARGES
var hiding_zone_count: int = 0

# References to nodes
@onready var attack_pivot: Node2D = $AttackPivot
@onready var attack_area: Area2D = $AttackPivot/AttackArea
@onready var hurtbox: Area2D = $Hurtbox
@onready var color_rect: ColorRect = $ColorRect
@onready var camera: Camera2D = $Camera2D
@onready var weapon_color_rect: ColorRect = $AttackPivot/AttackArea/ColorRect
@onready var dust_particles: CPUParticles2D = $DustParticles

func _ready() -> void:
	collision_layer = 1
	collision_mask = 1

	# Apply persistent weapon scale upgrades from the Global state!
	attack_pivot.scale = Global.weapon_scale
	
	# Disable and hide the attack hitbox at start
	attack_area.visible = false
	attack_area.monitorable = false
	attack_area.monitoring = false
	
	# Connect the player's Hurtbox signal to detect incoming enemy attacks
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(_delta: float) -> void:
	# 1. Decay the dash cooldown timer
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer = move_toward(dash_cooldown_timer, 0.0, _delta)
		
	# 2. Bypass normal inputs if currently dashing
	if is_dashing:
		move_and_slide()
		return
		
	# 3. Standard 8-way movement
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	
	# 4. Actions allowed ONLY in combat (Not safe mode)
	if not is_safe_mode:
		# Trigger Dash
		if Input.is_action_just_pressed("dash") and direction != Vector2.ZERO and dash_cooldown_timer == 0.0:
			start_dash(direction)
			
		# Trigger Attack
		if Input.is_action_just_pressed("attack") and not is_attacking:
			start_attack()

		if Input.is_action_just_pressed("throw_distraction") and not is_attacking:
			throw_distraction()
			
	# =========================================================
	# NOVO CÓDIGO DO MONÓCULO (SLOW MOTION) ENTRA AQUI:
	# =========================================================
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and current_focus > 0.0 and not is_safe_mode:
		is_using_monocle = true
		current_focus -= Global.focus_drain_rate * _delta
		Engine.time_scale = 0.3
	else:
		is_using_monocle = false
		Engine.time_scale = 1.0 # Normal speed
		
		# REGENERATION: Slowly recover focus when not in use
		if current_focus < MAX_FOCUS and not is_safe_mode:
			current_focus = move_toward(current_focus, MAX_FOCUS, 7.0 * _delta)
	# =========================================================

	# 5. Enable dust particles when running
	if velocity.length() > 0.0 and not is_dashing and not is_safe_mode:
		dust_particles.emitting = true
	else:
		dust_particles.emitting = false

	update_concealment_visual()
		
	# 6. Apply all physical movement
	move_and_slide()

func throw_distraction() -> void:
	if distraction_charges <= 0:
		return

	var target_position: Vector2 = get_global_mouse_position()
	var offset: Vector2 = target_position - global_position
	if offset.length() > DISTRACTION_RANGE:
		target_position = global_position + offset.normalized() * DISTRACTION_RANGE

	var distraction: Node2D = DISTRACTION_SCENE.instantiate() as Node2D
	if distraction == null:
		push_error("The distraction scene must have a Node2D-compatible root.")
		return

	distraction_charges -= 1
	get_parent().add_child(distraction)
	distraction.call("setup", global_position, target_position)

func enter_hiding_zone() -> void:
	hiding_zone_count += 1

func exit_hiding_zone() -> void:
	hiding_zone_count = maxi(0, hiding_zone_count - 1)

func is_concealed() -> bool:
	return hiding_zone_count > 0 and velocity.length() <= 35.0 and not is_attacking and not is_dashing

func update_concealment_visual() -> void:
	if is_concealed():
		color_rect.modulate = Color(0.48, 0.62, 0.52, 0.72)
	else:
		color_rect.modulate = Color.WHITE

func start_dash(dash_direction: Vector2) -> void:
	is_dashing = true
	dash_cooldown_timer = Global.dash_cooldown	
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
	
	# Calculate the angle pointing to the mouse from the player position
	var mouse_position: Vector2 = get_global_mouse_position()
	var base_angle: float = global_position.angle_to_point(mouse_position)
	
	# Set the initial rotation of the pivot to start 60 degrees behind the mouse angle
	attack_pivot.rotation = base_angle - deg_to_rad(60.0)
	
	# Make the weapon fully opaque (0.8 alpha) and active before starting the swing
	weapon_color_rect.color.a = 0.8
	attack_area.visible = true
	attack_area.monitorable = true
	attack_area.monitoring = true
	
	# Create a parallel Tween to animate both rotation and opacity at the same time
	var tween = create_tween().set_parallel(true)
	# Sweep the weapon in a 120-degree arc (from -60 to +60 degrees relative to base angle)
	tween.tween_property(attack_pivot, "rotation", base_angle + deg_to_rad(60.0), 0.15)
	# Smoothly fade out the weapon's opacity during the swing
	tween.tween_property(weapon_color_rect, "color:a", 0.0, 0.15)
	
	# Wait for the 0.15-second swing animation to finish
	await get_tree().create_timer(0.15).timeout
	
	# Disable the weapon hitboxes
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
	# A well-timed dash passes through danger. Brief recovery frames after a hit
	# prevent overlapping attacks from deleting the entire health bar at once.
	if is_dead or is_dashing or is_invulnerable:
		return

	is_invulnerable = true
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
		return

	await get_tree().create_timer(0.35).timeout
	is_invulnerable = false

func die() -> void:
	if is_dead:
		return

	is_dead = true
	print("Player died! Returning to the start of the loop...")
	Engine.time_scale = 1.0
	Global.record_failed_run()
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
		current_health = clampi(current_health + amount, 0, MAX_HEALTH)
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
