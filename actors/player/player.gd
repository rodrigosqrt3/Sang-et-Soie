extends CharacterBody2D

# Exported variable to toggle peace/combat mode in the Inspector
@export var is_safe_mode: bool = false

# Movement stats
const SPEED: float = 300.0
const DASH_SPEED: float = 1200.0
const DASH_DURATION: float = 0.15
const DISTRACTION_SCENE: PackedScene = preload("res://objects/props/distraction.tscn")
const MAX_DISTRACTION_CHARGES: int = 3
const DISTRACTION_RANGE: float = 250.0
const SOCIAL_WALK_SPEED: float = 125.0
const HIDING_MAX_SPEED: float = 35.0

# Attack timing. The recovery stops click-spamming from replacing positioning.
const ATTACK_SWING_TIME: float = 0.15
const ATTACK_RECOVERY_TIME: float = 0.12

# Le Regard slows the world, but Étienne keeps part of his real-time speed.
# That gap is what makes the monocle a tool for slipping past a guard's gaze.
const REGARD_TIME_SCALE: float = 0.35
const REGARD_REAL_SPEED_FACTOR: float = 0.55

# Player health stats
const MAX_HEALTH: int = 3
var current_health: int = MAX_HEALTH
var dash_cooldown_timer: float = 0.0
var attack_cooldown_timer: float = 0.0

# Focus System (The "Mana" for Le Regard)
const MAX_FOCUS: float = 100.0
const FOCUS_REGEN_RATE: float = 7.0
var current_focus: float = MAX_FOCUS
var is_using_monocle: bool = false

# Color variables for visual feedback
const EMERALD_GREEN = Color(0.14, 0.45, 0.23)
const DAMAGE_COLOR = Color.RED
const HEAL_COLOR = Color(0.8, 0.6, 0.0)

# State variables
var is_dashing: bool = false
var is_attacking: bool = false
var is_dead: bool = false
var is_invulnerable: bool = false
var distraction_charges: int = MAX_DISTRACTION_CHARGES

# Concealment sources are tracked by instance id instead of a counter, so a
# zone that reports its exit twice (or is freed) can never desync the state.
var hiding_sources: Dictionary = {}
var blend_sources: Dictionary = {}

# References to nodes
@onready var attack_pivot: Node2D = $AttackPivot
@onready var attack_area: Area2D = $AttackPivot/AttackArea
@onready var hurtbox: Area2D = $Hurtbox
@onready var color_rect: ColorRect = $ColorRect
@onready var camera: Camera2D = $Camera2D
@onready var weapon_color_rect: ColorRect = $AttackPivot/AttackArea/ColorRect
@onready var dust_particles: CPUParticles2D = $DustParticles

# Étienne as a paper puppet. The old ColorRect stays hidden for scripts that
# still look it up, but every visual now goes through the figure.
var figure: PaperFigure

func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	color_rect.color = EMERALD_GREEN
	color_rect.visible = false
	figure = PaperFigure.new()
	figure.look = CharacterData.get_look("etienne", Global.get_district_of(self))
	figure.seed_id = 7
	add_child(figure)
	move_child(figure, color_rect.get_index() + 1)

	# Apply persistent weapon scale upgrades from the Global state!
	attack_pivot.scale = Global.weapon_scale

	# Disable and hide the attack hitbox at start
	attack_area.visible = false
	attack_area.monitorable = false
	attack_area.monitoring = false

	# Connect the player's Hurtbox signal to detect incoming enemy attacks
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	Global.restore_player_run_state(self)

func _exit_tree() -> void:
	Engine.time_scale = 1.0
	if not is_dead:
		Global.capture_player_run_state(self)

func _physics_process(delta: float) -> void:
	# Scene transitions freeze Étienne so he cannot walk, act or die mid-fade.
	if is_dead or Global.scene_transition_in_progress:
		velocity = Vector2.ZERO
		dust_particles.emitting = false
		stop_regard()
		return

	# 1. Decay the cooldown timers
	dash_cooldown_timer = move_toward(dash_cooldown_timer, 0.0, delta)
	attack_cooldown_timer = move_toward(attack_cooldown_timer, 0.0, delta)

	# 2. Bypass normal inputs if currently dashing
	if is_dashing:
		move_and_slide()
		return

	update_regard(delta)

	# 3. Standard 8-way movement
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	var movement_speed: float = SOCIAL_WALK_SPEED if is_blending() else SPEED
	velocity = direction * movement_speed * get_regard_speed_compensation()

	# 4. Actions allowed ONLY in combat (Not safe mode)
	if not is_safe_mode:
		if Input.is_action_just_pressed("dash") and direction != Vector2.ZERO and dash_cooldown_timer == 0.0:
			start_dash(direction)

		if Input.is_action_just_pressed("attack") and not is_attacking and attack_cooldown_timer == 0.0:
			start_attack()

		if Input.is_action_just_pressed("throw_distraction") and not is_attacking:
			throw_distraction()

	# 5. Enable dust particles when running
	dust_particles.emitting = velocity.length() > 0.0 and not is_safe_mode and not is_blending()

	figure.moving_ratio = clampf(get_real_speed() / SPEED, 0.0, 1.0)
	if absf(direction.x) > 0.1:
		figure.facing_left = direction.x < 0.0
	update_concealment_visual()

	# 6. Apply all physical movement
	move_and_slide()

# =========================================================
# LE REGARD
# =========================================================
func update_regard(delta: float) -> void:
	if not is_safe_mode and Input.is_action_pressed("regard") and current_focus > 0.0:
		is_using_monocle = true
		current_focus = maxf(0.0, current_focus - Global.focus_drain_rate * delta)
		Engine.time_scale = REGARD_TIME_SCALE
		return

	stop_regard()
	if current_focus < MAX_FOCUS and not is_safe_mode:
		current_focus = move_toward(current_focus, MAX_FOCUS, FOCUS_REGEN_RATE * delta)

func stop_regard() -> void:
	is_using_monocle = false
	Engine.time_scale = 1.0

# Velocity is measured in scaled time. Dividing by the time scale converts the
# desired real-time speed into the value move_and_slide expects.
func get_regard_speed_compensation() -> float:
	if not is_using_monocle:
		return 1.0
	return REGARD_REAL_SPEED_FACTOR / REGARD_TIME_SCALE

func get_real_speed() -> float:
	return velocity.length() * Engine.time_scale

# =========================================================
# STEALTH
# =========================================================
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

func enter_hiding_zone(source: Node) -> void:
	hiding_sources[source.get_instance_id()] = true

func exit_hiding_zone(source: Node) -> void:
	hiding_sources.erase(source.get_instance_id())

func enter_social_blend(source: Node) -> void:
	blend_sources[source.get_instance_id()] = true

func exit_social_blend(source: Node) -> void:
	blend_sources.erase(source.get_instance_id())

func is_blending() -> bool:
	return not blend_sources.is_empty()

func is_concealed() -> bool:
	return get_stealth_state() != "EXPOSED"

func get_stealth_state() -> String:
	if is_attacking or is_dashing:
		return "EXPOSED"
	var real_speed: float = get_real_speed()
	if not hiding_sources.is_empty() and real_speed <= HIDING_MAX_SPEED:
		return "HIDDEN"
	if is_blending() and real_speed <= SOCIAL_WALK_SPEED + 5.0:
		return "BLENDED"
	return "EXPOSED"

func update_concealment_visual() -> void:
	var stealth_state: String = get_stealth_state()
	if stealth_state == "HIDDEN":
		figure.modulate = Color(0.48, 0.62, 0.52, 0.72)
	elif stealth_state == "BLENDED":
		figure.modulate = Color(0.68, 0.72, 0.82, 0.82)
	else:
		figure.modulate = Color.WHITE

# =========================================================
# COMBAT
# =========================================================
func start_dash(dash_direction: Vector2) -> void:
	is_dashing = true
	dash_cooldown_timer = Global.dash_cooldown
	velocity = dash_direction * DASH_SPEED * get_regard_speed_compensation()

	# Spawn three ghosts at short intervals (0.05 seconds) during the 0.15s dash
	spawn_ghost_effect()
	await get_tree().create_timer(DASH_DURATION / 3.0).timeout
	spawn_ghost_effect()
	await get_tree().create_timer(DASH_DURATION / 3.0).timeout
	spawn_ghost_effect()

	# Wait the final remaining third of the dash
	await get_tree().create_timer(DASH_DURATION / 3.0).timeout
	is_dashing = false

func start_attack() -> void:
	is_attacking = true

	# Calculate the angle pointing to the mouse from the player position
	var mouse_position: Vector2 = get_global_mouse_position()
	var base_angle: float = global_position.angle_to_point(mouse_position)
	figure.face_toward(mouse_position - global_position)

	# Set the initial rotation of the pivot to start 60 degrees behind the mouse angle
	attack_pivot.rotation = base_angle - deg_to_rad(60.0)

	# Make the weapon fully opaque (0.8 alpha) and active before starting the swing
	weapon_color_rect.color.a = 0.8
	attack_area.visible = true
	attack_area.monitorable = true
	attack_area.monitoring = true

	# Sweep the weapon in a 120-degree arc while it fades out
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(attack_pivot, "rotation", base_angle + deg_to_rad(60.0), ATTACK_SWING_TIME)
	tween.tween_property(weapon_color_rect, "color:a", 0.0, ATTACK_SWING_TIME)

	await get_tree().create_timer(ATTACK_SWING_TIME).timeout

	# Disable the weapon hitboxes
	attack_area.visible = false
	attack_area.monitorable = false
	attack_area.monitoring = false
	is_attacking = false
	attack_cooldown_timer = ATTACK_RECOVERY_TIME

# This function runs automatically when an Area enters the Player's Hurtbox
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "Hitbox":
		take_damage(1)

func take_damage(amount: int) -> void:
	# A well-timed dash passes through danger. Brief recovery frames after a hit
	# prevent overlapping attacks from deleting the entire health bar at once.
	if is_dead or is_dashing or is_invulnerable or Global.scene_transition_in_progress:
		return

	is_invulnerable = true
	current_health -= amount
	camera.apply_shake(18.0, 4.0)

	# Visual feedback: Flash Red when taking damage
	figure.set_flash(DAMAGE_COLOR, 0.8)
	await get_tree().create_timer(0.1).timeout
	figure.set_flash(Color.WHITE, 0.0)

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
	stop_regard()
	# The puppet falls flat, pinned at its feet.
	create_tween().tween_property(figure, "lean", 1.5, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	Global.record_failed_run()
	Global.transition_to_scene.call_deferred("res://levels/hub/bal_des_victimes.tscn")

# Public function for other nodes (like enemies) to trigger camera shake
func shake_camera(strength: float, decay: float = 5.0) -> void:
	camera.apply_shake(strength, decay)

# Public function to freeze the frame momentarily (Hit-Stop)
func freeze_frame(duration: float, time_scale: float = 0.0) -> void:
	Engine.time_scale = time_scale

	# Create a timer that ignores the time_scale so it can finish in real-world time
	await get_tree().create_timer(duration, true, false, true).timeout

	# Return to whatever speed the world should run at, not blindly to 1.0.
	Engine.time_scale = REGARD_TIME_SCALE if is_using_monocle else 1.0

# Public function to heal the player (Anesthesia). Returns whether it healed,
# so pickups are only consumed when they actually help.
func heal(amount: int) -> bool:
	if is_dead or current_health >= MAX_HEALTH:
		return false
	current_health = clampi(current_health + amount, 0, MAX_HEALTH)
	flash_heal()
	return true

# Visual feedback: Flash Gold when healing. Kept separate so heal() stays
# synchronous and can return its result to the caller.
func flash_heal() -> void:
	figure.flash(HEAL_COLOR, 0.12)

# Public flash for pickups and story moments (the key, the ledger).
func flash_gold() -> void:
	figure.flash(HEAL_COLOR, 0.2)

# Spawns a fading paper copy of Étienne where he was: the dash as a dance step.
func spawn_ghost_effect() -> void:
	var ghost: PaperFigure = PaperFigure.new()
	ghost.look = figure.look
	ghost.seed_id = figure.seed_id
	ghost.facing_left = figure.facing_left
	ghost.global_position = global_position
	ghost.modulate = Color(0.55, 0.95, 0.8, 0.45)

	# Add the ghost to the World scene so it stays fixed on the ground while we move
	get_parent().add_child(ghost)

	var tween: Tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.25)
	tween.tween_callback(ghost.queue_free)
