extends MeleeGuard

const PROJECTILE_SCENE: PackedScene = preload("res://actors/enemies/projectile.tscn")
const STOP_DISTANCE: float = 245.0
const RETREAT_DISTANCE: float = 145.0

@onready var shoot_timer: Timer = $ShootTimer

func _ready() -> void:
	max_health = 3
	speed = 82.0
	default_color = Color(0.16, 0.50, 0.72)
	detection_range = 390.0
	vision_half_angle_degrees = 38.0
	guard_kind = "ranged"
	super()
	shoot_timer.one_shot = true
	shoot_timer.start(0.8)

func combat_behavior(player: CharacterBody2D) -> void:
	var distance: float = global_position.distance_to(player.global_position)
	var direction: Vector2 = global_position.direction_to(player.global_position)
	set_facing(direction)

	if distance > STOP_DISTANCE:
		velocity = direction * speed
	elif distance < RETREAT_DISTANCE:
		velocity = -direction * speed * 0.75
	else:
		velocity = Vector2.ZERO
	move_and_slide()

	if shoot_timer.is_stopped() and can_see_player(player):
		shoot_at_player(player)

func shoot_at_player(player: CharacterBody2D) -> void:
	shoot_timer.start(2.2)
	velocity = Vector2.ZERO
	show_awareness("!")
	shout_dialogue("Stand where you are!")
	set_tint(Color(0.55, 0.8, 1.0), 0.5)
	await get_tree().create_timer(0.35).timeout
	if is_dead or awareness != Awareness.ALERT:
		set_tint(Color.WHITE, 0.0)
		return

	var projectile_node: Node = PROJECTILE_SCENE.instantiate()
	if not projectile_node is Node2D:
		push_error("The projectile scene must have a Node2D-compatible root.")
		projectile_node.queue_free()
		set_tint(Color.WHITE, 0.0)
		return

	var projectile: Node2D = projectile_node as Node2D
	var direction: Vector2 = global_position.direction_to(player.global_position)
	projectile.position = position + direction * 25.0
	projectile.set("direction", direction)
	get_parent().add_child(projectile)
	set_tint(Color.WHITE, 0.0)
