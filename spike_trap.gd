extends Area2D

# Colors for different trap states
const IDLE_COLOR = Color(0.2, 0.29, 0.37)     # Dark slate gray (#34495e)
const WARNING_COLOR = Color(0.9, 0.3, 0.23)    # Bright warning red (#e74c3c)
const ACTIVE_COLOR = Color(0.92, 0.94, 0.95)   # Silver/white spikes (#ecf0f1)

# State variables
var is_triggered: bool = false
var overlapping_bodies: Array[Node2D] = []

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.color = IDLE_COLOR
	# Connect physics signals to track bodies entering/exiting the trap
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	# We only care about the player and active enemies
	if body.is_in_group("player") or body.is_in_group("enemies"):
		if not overlapping_bodies.has(body):
			overlapping_bodies.append(body)
		
		# If the trap isn't already triggered, start the warning and spike routine!
		if not is_triggered:
			trigger_trap()

func _on_body_exited(body: Node2D) -> void:
	# Remove the body from our tracking list when they walk off the trap
	if overlapping_bodies.has(body):
		overlapping_bodies.erase(body)

func trigger_trap() -> void:
	is_triggered = true
	
	# 1. Warning Phase: Flash bright red for 0.5 seconds to warn the player
	color_rect.color = WARNING_COLOR
	await get_tree().create_timer(0.5).timeout
	
	# 2. Active Phase: Shoot spikes (change color to silver/white)
	color_rect.color = ACTIVE_COLOR
	
	# Deal 1 damage to ALL bodies currently standing on the trap at this exact millisecond!
	for body in overlapping_bodies:
		if is_instance_valid(body) and body.has_method("take_damage"):
			body.take_damage(1)
			
	# Keep the spikes active and dangerous for 0.3 seconds
	await get_tree().create_timer(0.3).timeout
	
	# 3. Reset Phase: Retract spikes and enter a 1.5-second cooldown
	color_rect.color = IDLE_COLOR
	await get_tree().create_timer(1.5).timeout
	
	is_triggered = false
	
	# If someone is still standing on the trap after cooldown, trigger it again!
	if overlapping_bodies.size() > 0:
		trigger_trap()