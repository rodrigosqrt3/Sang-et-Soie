extends CharacterBody2D

# Enemy stats
const MAX_HEALTH: int = 3
var current_health: int = MAX_HEALTH

# Movement speed (when chasing the player)
const SPEED: float = 120.0

# Knockback stats
var knockback_velocity: Vector2 = Vector2.ZERO
const KNOCKBACK_DECAY: float = 15.0

# Historical French Revolutionary insults (barks)
const BARKS: Array[String] = [
	"Aristocrate!",
	"À la lanterne!",      # "To the lantern!" (Revolutionary hanging cry)
	"À bas les dandys!",   # "Down with the dandies!"
	"Pour la République!", # "For the Republic!"
	"Muscadin!",           # "Perfumed dandy!" (Jacobin insult)
	"Traître!"             # "Traitor!"
]

# Dialogue timer variables
var bark_timer: float = 0.0
const BARK_COOLDOWN: float = 4.0 # Seconds between dialogue checks

# Color variables for the hit flash effect
const RED_COLOR = Color(0.6, 0.0, 0.0)
const FLASH_COLOR = Color.WHITE

# References to nodes
@onready var hurtbox: Area2D = $Hurtbox
@onready var color_rect: ColorRect = $ColorRect
@onready var bark_label: Label = $BarkLabel

func _ready() -> void:
	# Ensure the speech bubble is empty and hidden at start
	bark_label.text = ""
	bark_label.visible = false
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(delta: float) -> void:
	# 1. If we have active knockback, apply it and decay it
	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta * 150.0)
		move_and_slide()
		return
		
	# Handle random dialogue barks while chasing
	bark_timer += delta
	if bark_timer >= BARK_COOLDOWN:
		bark_timer = 0.0
		# 25% chance to shout a historical insult every 4 seconds
		if randf() < 0.25:
			shout_dialogue(BARKS[randi() % BARKS.size()])
			
	# Find the player using the global "player" group
	var players = get_tree().get_nodes_in_group("player")
	
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * SPEED
		move_and_slide()

# Function to show a floating speech bubble above the enemy
func shout_dialogue(text: String) -> void:
	bark_label.text = text
	bark_label.visible = true
	
	# Keep the dialogue visible for 1.5 seconds, then hide it
	await get_tree().create_timer(1.5).timeout
	bark_label.visible = false
	bark_label.text = ""

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		take_damage(1)

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Enemy took damage! Remaining HP: ", current_health)
	
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
	color_rect.color = RED_COLOR
	
	if current_health <= 0:
		die()

func die() -> void:
	print("Enemy defeated!")
	
	if get_parent().has_method("add_score"):
		get_parent().add_score(1)
	
	# Hide the visual body of the enemy instantly
	color_rect.visible = false
	
	# Safely disable hurtbox in physics thread
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	
	# Safely disable the physical collision
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Hide the dialogue label upon death
	bark_label.visible = false
	
	# Destroy the node immediately since we don't have death particles
	queue_free()
