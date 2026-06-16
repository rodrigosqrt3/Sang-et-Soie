extends CharacterBody2D

const SPEED = 300.0
const DASH_SPEED = 1200.0
const DASH_DURATION = 0.15

var is_dashing: bool = false
var is_attacking: bool = false

# References to our visual nodes using @onready (loaded when the game starts)
@onready var attack_pivot: Node2D = $AttackPivot
@onready var attack_area: Area2D = $AttackPivot/AttackArea

func _ready() -> void:
	# Disable and hide the weapon area when the game starts
	attack_area.visible = false
	attack_area.monitorable = false
	attack_area.monitoring = false

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
	
	# Calculate mouse position in the world and rotate the weapon pivot towards it
	var mouse_position := get_global_mouse_position()
	attack_pivot.look_at(mouse_position)
	
	# Enable and show the weapon hitbox and visual representation
	attack_area.visible = true
	attack_area.monitorable = true
	attack_area.monitoring = true
	
	# Keep the slash active for 0.15 seconds
	await get_tree().create_timer(0.15).timeout
	
	# Hide and disable the weapon hitbox
	attack_area.visible = false
	attack_area.monitorable = false
	attack_area.monitoring = false
	is_attacking = false