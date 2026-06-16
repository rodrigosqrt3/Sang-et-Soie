extends Area2D

const SPEED: float = 350.0
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Destroy itself when hitting static walls/obstacles or the player body
	body_entered.connect(_on_body_entered)
	# Destroy itself when hitting the player's Hurtbox
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	# Move the projectile forward in a straight line
	global_position += direction * SPEED * delta

func _on_body_entered(_body: Node2D) -> void:
	# Hits a wall or body: disappear
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Hits the player's Hurtbox: disappear (the player script handles taking damage!)
	if area.name == "Hurtbox":
		queue_free()