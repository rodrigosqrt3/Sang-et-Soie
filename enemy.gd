extends CharacterBody2D

# Exported variables to customize enemy types easily in the Inspector
@export var max_health: int = 3
@export var speed: float = 120.0
@export var default_color: Color = Color(0.6, 0.0, 0.0) # Default dark red

var current_health: int
# Attack states
var is_attacking: bool = false
const ATTACK_RANGE: float = 75.0    # Distance to trigger the saber swing
const ATTACK_COOLDOWN: float = 2.0  # Cooldown between saber swings
var attack_cooldown_timer: float = 0.0

# Knockback stats
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_DECAY: float = 15.0

# Historical French Revolutionary insults (barks)
const BARKS: Array[String] = [
	"Aristocrate!",
	"À la lanterne!",      
	"À bas les dandys!",   
	"Pour la République!", 
	"Muscadin!",           
	"Traître!"             
]

# Dialogue timer variables
var bark_timer: float = 0.0
const BARK_COOLDOWN: float = 4.0

# Color variables for the hit flash effect
const FLASH_COLOR = Color.WHITE

# References to nodes
@onready var hurtbox: Area2D = $Hurtbox
@onready var color_rect: ColorRect = $ColorRect
@onready var bark_label: Label = $BarkLabel

func _ready() -> void:
	current_health = max_health
	color_rect.color = default_color
	
	# Ensure the weapon hitbox starts disabled
	$Hitbox.visible = false
	$Hitbox.monitoring = false
	$Hitbox.monitorable = false
	
	bark_label.text = ""
	bark_label.visible = false
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(delta: float) -> void:
	# 1. Decay knockback if active
	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta * 150.0)
		move_and_slide()
		return
		
	# 2. Decay attack cooldown timer
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer = move_toward(attack_cooldown_timer, 0.0, delta)
		
	# If currently performing the attack swing, stay in place
	if is_attacking:
		return
		
	# Handle random barks while chasing
	bark_timer += delta
	if bark_timer >= BARK_COOLDOWN:
		bark_timer = 0.0
		if randf() < 0.25:
			shout_dialogue(BARKS[randi() % BARKS.size()])
			
	# 3. Find the player to chase or attack
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		var distance = global_position.distance_to(player.global_position)
		var direction = global_position.direction_to(player.global_position)
		
		# If in range and cooldown is ready, attack! Otherwise, chase.
		if distance <= ATTACK_RANGE and attack_cooldown_timer == 0.0:
			start_attack_routine(direction)
		else:
			velocity = direction * speed
			move_and_slide()

# Function to show a floating speech bubble above the enemy
func shout_dialogue(text: String) -> void:
	bark_label.text = text
	bark_label.visible = true
	await get_tree().create_timer(1.5).timeout
	bark_label.visible = false
	bark_label.text = ""

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		take_damage(1)

func take_damage(amount: int) -> void:
	current_health -= amount
	print(name, " took damage! Remaining HP: ", current_health)
	
	# Shout a pain cry on hit
	shout_dialogue("Aïe!")
	
	# Apply Knockback, Camera Shake, and Hit-Stop on successful impact
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
	
	# Flash back to our exported default color!
	color_rect.color = default_color
	
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
	bark_label.visible = false
	queue_free()

# Performs the Sabre-Briquet active attack swing
func start_attack_routine(attack_direction: Vector2) -> void:
	is_attacking = true
	attack_cooldown_timer = ATTACK_COOLDOWN
	
	# 1. Shouts a battle cry!
	shout_dialogue("À mort!")
	
	# 2. Telegraph (Wind-up): Flash yellow to warn the player to dodge!
	color_rect.color = Color.YELLOW
	await get_tree().create_timer(0.4).timeout
	color_rect.color = default_color
	
	# 3. Swing Phase: Position the hitbox towards the player and enable it
	var hitbox = $Hitbox
	hitbox.position = attack_direction * 25.0 # Project hitbox forward
	
	# ADD THIS LINE: Mathematically rotates the sword to face the attack direction!
	hitbox.rotation = attack_direction.angle()
	
	hitbox.visible = true
	hitbox.monitoring = true
	hitbox.monitorable = true
	
	# Keep the saber hitbox active for 0.15 seconds
	await get_tree().create_timer(0.15).timeout
	
	# 4. Recovery Phase: Disable hitbox and resume chasing
	hitbox.visible = false
	hitbox.monitoring = false
	hitbox.monitorable = false
	is_attacking = false
