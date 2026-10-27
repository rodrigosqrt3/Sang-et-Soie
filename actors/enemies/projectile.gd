extends Area2D

@export var speed: float = 360.0
@export var lifetime: float = 4.0

var direction: Vector2 = Vector2.RIGHT
var elapsed_time: float = 0.0
var has_hit: bool = false

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	elapsed_time += delta
	if elapsed_time >= lifetime:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if has_hit:
		return

	# A projectile must be able to leave its shooter without striking it.
	if body.is_in_group("enemies") or body.is_in_group("boss"):
		return

	has_hit = true
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.call("take_damage", 1)
	queue_free()