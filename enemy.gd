extends CharacterBody2D
class_name MeleeGuard

enum Awareness {
	PATROL,
	SUSPICIOUS,
	ALERT,
	SEARCHING
}

@export var max_health: int = 3
@export var speed: float = 120.0
@export var default_color: Color = Color(0.6, 0.0, 0.0)
@export var detection_range: float = 280.0
@export var vision_half_angle_degrees: float = 52.0
@export var hearing_range: float = 250.0
@export var persistent_guard: bool = true

const ATTACK_RANGE: float = 75.0
const ATTACK_COOLDOWN: float = 2.0
const KNOCKBACK_DECAY: float = 15.0
const SUSPICION_GAIN: float = 1.35
const SUSPICION_LOSS: float = 0.55
const SEARCH_DURATION: float = 4.0
const FLASH_COLOR: Color = Color.WHITE

const ALERT_BARKS: Array[String] = [
	"Halt!",
	"Muscadin!",
	"You there!",
	"À la garde!"
]

var current_health: int = 0
var awareness: Awareness = Awareness.PATROL
var suspicion: float = 0.0
var search_timer: float = 0.0
var patrol_change_timer: float = 0.0
var patrol_wait_timer: float = 0.0
var attack_cooldown_timer: float = 0.0
var bark_timer: float = 0.0
var is_attacking: bool = false
var is_dead: bool = false
var has_reported_detection: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var facing_direction: Vector2 = Vector2.RIGHT
var patrol_direction: Vector2 = Vector2.RIGHT
var last_known_position: Vector2 = Vector2.ZERO
var patrol_route: Array[Vector2] = []
var patrol_route_index: int = 0

@onready var hurtbox: Area2D = $Hurtbox
@onready var hitbox: Area2D = $Hitbox
@onready var color_rect: ColorRect = $ColorRect
@onready var bark_label: Label = $BarkLabel
@onready var awareness_label: Label = get_node_or_null("AwarenessLabel") as Label
@onready var vision_pivot: Node2D = get_node_or_null("VisionPivot") as Node2D
@onready var vision_cone: Polygon2D = get_node_or_null("VisionPivot/VisionCone") as Polygon2D

func _ready() -> void:
	add_to_group("enemies")
	collision_layer = 1
	collision_mask = 1
	current_health = max_health
	color_rect.color = default_color
	ensure_awareness_visuals()
	hitbox.visible = false
	hitbox.monitoring = false
	hitbox.monitorable = false
	bark_label.visible = false
	awareness_label.visible = false
	vision_cone.visible = false
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	choose_new_patrol_direction()

func ensure_awareness_visuals() -> void:
	# Some older enemy scenes do not contain these presentation nodes. Creating
	# them here keeps every enemy variant compatible while the prototype evolves.
	if awareness_label == null:
		awareness_label = Label.new()
		awareness_label.name = "AwarenessLabel"
		awareness_label.position = Vector2(-18.0, -42.0)
		awareness_label.size = Vector2(36.0, 24.0)
		awareness_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		awareness_label.add_theme_font_size_override("font_size", 18)
		awareness_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.28))
		add_child(awareness_label)

	if vision_pivot == null:
		vision_pivot = Node2D.new()
		vision_pivot.name = "VisionPivot"
		vision_pivot.z_index = -1
		add_child(vision_pivot)

	if vision_cone == null:
		vision_cone = Polygon2D.new()
		vision_cone.name = "VisionCone"
		vision_pivot.add_child(vision_cone)

	var cone_half_width: float = tan(deg_to_rad(vision_half_angle_degrees)) * detection_range
	vision_cone.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(detection_range, -cone_half_width),
		Vector2(detection_range, cone_half_width)
	])
	vision_pivot.z_index = -1

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta * 150.0)
		move_and_slide()
		return

	attack_cooldown_timer = maxf(0.0, attack_cooldown_timer - delta)
	bark_timer = maxf(0.0, bark_timer - delta)

	var player: CharacterBody2D = get_player()
	if player == null:
		velocity = Vector2.ZERO
		return

	update_awareness(player, delta)
	update_vision_display(player)

	if is_attacking:
		velocity = Vector2.ZERO
		return

	match awareness:
		Awareness.PATROL:
			patrol(delta)
		Awareness.SUSPICIOUS:
			velocity = Vector2.ZERO
			face_toward(last_known_position)
		Awareness.ALERT:
			combat_behavior(player)
		Awareness.SEARCHING:
			search_last_position(delta)

func get_player() -> CharacterBody2D:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return null
	return players[0] as CharacterBody2D

func update_awareness(player: CharacterBody2D, delta: float) -> void:
	var player_visible: bool = can_see_player(player)
	if player_visible:
		last_known_position = player.global_position
		var distance: float = global_position.distance_to(player.global_position)
		var proximity_bonus: float = 1.65 if distance < 130.0 else 1.0
		suspicion = minf(1.0, suspicion + SUSPICION_GAIN * proximity_bonus * delta)

		if awareness == Awareness.PATROL and suspicion >= 0.12:
			awareness = Awareness.SUSPICIOUS
			show_awareness("?")
			shout_dialogue("Who goes there?")

		if suspicion >= 1.0 and awareness != Awareness.ALERT:
			become_alerted(true)
	else:
		if awareness == Awareness.SUSPICIOUS:
			suspicion = maxf(0.0, suspicion - SUSPICION_LOSS * delta)
			if suspicion <= 0.0:
				awareness = Awareness.PATROL
				hide_awareness()
		elif awareness == Awareness.ALERT:
			awareness = Awareness.SEARCHING
			search_timer = SEARCH_DURATION
			show_awareness("?")
		elif awareness == Awareness.SEARCHING:
			search_timer = maxf(0.0, search_timer - delta)
			if search_timer <= 0.0:
				awareness = Awareness.PATROL
				suspicion = 0.0
				hide_awareness()
				if patrol_route.is_empty():
					choose_new_patrol_direction()

func can_see_player(player: CharacterBody2D) -> bool:
	var to_player: Vector2 = player.global_position - global_position
	var distance: float = to_player.length()
	if distance > detection_range or distance <= 0.01:
		return false

	# Shadows break recognition at a distance, but not if a guard walks directly
	# into Étienne. Movement or combat also cancels concealment on the player side.
	if awareness != Awareness.ALERT and distance > 55.0 and player.has_method("is_concealed"):
		var concealed: bool = bool(player.call("is_concealed"))
		if concealed:
			return false

	var direction_to_player: Vector2 = to_player / distance
	var vision_threshold: float = cos(deg_to_rad(vision_half_angle_degrees))
	if facing_direction.dot(direction_to_player) < vision_threshold:
		return false

	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	query.collision_mask = 1
	query.exclude = [get_rid()]
	var result: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return true
	var collider: Object = result.get("collider") as Object
	return collider == player

func patrol(delta: float) -> void:
	if not patrol_route.is_empty():
		follow_patrol_route(delta)
		return

	patrol_change_timer -= delta
	velocity = patrol_direction * speed * 0.38
	set_facing(patrol_direction)
	move_and_slide()
	if patrol_change_timer <= 0.0 or get_slide_collision_count() > 0:
		choose_new_patrol_direction()

func follow_patrol_route(delta: float) -> void:
	if patrol_wait_timer > 0.0:
		patrol_wait_timer = maxf(0.0, patrol_wait_timer - delta)
		velocity = Vector2.ZERO
		return

	var route_target: Vector2 = patrol_route[patrol_route_index]
	var distance: float = global_position.distance_to(route_target)
	if distance <= 12.0:
		patrol_route_index = (patrol_route_index + 1) % patrol_route.size()
		patrol_wait_timer = 0.55
		velocity = Vector2.ZERO
		return

	var route_direction: Vector2 = global_position.direction_to(route_target)
	set_facing(route_direction)
	velocity = route_direction * speed * 0.42
	move_and_slide()
	if get_slide_collision_count() > 0:
		patrol_route_index = (patrol_route_index + 1) % patrol_route.size()
		patrol_wait_timer = 0.35

func choose_new_patrol_direction() -> void:
	var direction_index: int = randi_range(0, 3)
	match direction_index:
		0:
			patrol_direction = Vector2.RIGHT
		1:
			patrol_direction = Vector2.LEFT
		2:
			patrol_direction = Vector2.UP
		_:
			patrol_direction = Vector2.DOWN
	patrol_change_timer = randf_range(1.2, 2.8)
	set_facing(patrol_direction)

func set_patrol_direction(direction: Vector2) -> void:
	if direction.length_squared() <= 0.01:
		return
	patrol_direction = direction.normalized()
	patrol_change_timer = randf_range(1.5, 3.0)
	set_facing(patrol_direction)

func set_patrol_route(route_points: Array[Vector2]) -> void:
	patrol_route.clear()
	for route_point_index in range(route_points.size()):
		patrol_route.append(route_points[route_point_index])
	patrol_route_index = 0
	patrol_wait_timer = 0.0
	if not patrol_route.is_empty():
		face_toward(patrol_route[0])

func combat_behavior(player: CharacterBody2D) -> void:
	var distance: float = global_position.distance_to(player.global_position)
	var direction: Vector2 = global_position.direction_to(player.global_position)
	set_facing(direction)

	if bark_timer <= 0.0 and randf() < 0.012:
		bark_timer = 3.5
		var bark_index: int = randi_range(0, ALERT_BARKS.size() - 1)
		shout_dialogue(ALERT_BARKS[bark_index])

	if distance <= ATTACK_RANGE and attack_cooldown_timer <= 0.0:
		start_attack_routine(direction)
	else:
		velocity = direction * speed
		move_and_slide()

func search_last_position(_delta: float) -> void:
	var distance: float = global_position.distance_to(last_known_position)
	if distance <= 18.0:
		velocity = Vector2.ZERO
		return
	var direction: Vector2 = global_position.direction_to(last_known_position)
	set_facing(direction)
	velocity = direction * speed * 0.62
	move_and_slide()

func become_alerted(report_detection: bool) -> void:
	awareness = Awareness.ALERT
	suspicion = 1.0
	show_awareness("!")
	shout_dialogue("There! Stop!")

	if report_detection and not has_reported_detection:
		has_reported_detection = true
		var level: Node = get_parent()
		if level.has_method("register_detection"):
			level.call("register_detection")
		else:
			Global.exposure += 1
		get_tree().call_group("enemies", "receive_alert", last_known_position)

func receive_alert(alert_position: Vector2) -> void:
	if is_dead or awareness == Awareness.ALERT:
		return
	last_known_position = alert_position
	awareness = Awareness.SEARCHING
	search_timer = SEARCH_DURATION + 1.0
	suspicion = maxf(suspicion, 0.35)
	show_awareness("?")

func apply_district_alert(alert_level: int, search_origin: Vector2) -> void:
	if is_dead or alert_level <= 0:
		return
	last_known_position = search_origin
	awareness = Awareness.SEARCHING
	if alert_level >= 2:
		suspicion = maxf(suspicion, 0.72)
		search_timer = SEARCH_DURATION + 5.0
		show_awareness("!")
	else:
		suspicion = maxf(suspicion, 0.28)
		search_timer = SEARCH_DURATION + 1.5
		show_awareness("?")
	face_toward(search_origin)

func hear_distraction(noise_position: Vector2) -> void:
	if is_dead or awareness == Awareness.ALERT:
		return
	if global_position.distance_to(noise_position) > hearing_range:
		return

	last_known_position = noise_position
	awareness = Awareness.SEARCHING
	search_timer = 3.8
	suspicion = maxf(suspicion, 0.28)
	show_awareness("?")
	face_toward(noise_position)
	shout_dialogue("What was that?")

func face_toward(target_position: Vector2) -> void:
	var direction: Vector2 = global_position.direction_to(target_position)
	set_facing(direction)

func set_facing(direction: Vector2) -> void:
	if direction.length_squared() <= 0.01:
		return
	facing_direction = direction.normalized()
	vision_pivot.rotation = facing_direction.angle()

func update_vision_display(player: CharacterBody2D) -> void:
	var monocle_active: bool = bool(player.get("is_using_monocle"))
	vision_cone.visible = monocle_active or awareness != Awareness.PATROL
	if awareness == Awareness.ALERT:
		vision_cone.color = Color(0.9, 0.12, 0.1, 0.28)
	elif awareness == Awareness.SUSPICIOUS or awareness == Awareness.SEARCHING:
		vision_cone.color = Color(0.95, 0.7, 0.12, 0.2)
	else:
		vision_cone.color = Color(0.75, 0.62, 0.25, 0.13)

func show_awareness(symbol: String) -> void:
	awareness_label.text = symbol
	awareness_label.visible = true

func hide_awareness() -> void:
	awareness_label.visible = false

func shout_dialogue(text: String) -> void:
	bark_label.text = text
	bark_label.visible = true
	await get_tree().create_timer(1.4).timeout
	if is_instance_valid(bark_label):
		bark_label.visible = false
		bark_label.text = ""

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		take_damage(1)

func take_damage(amount: int) -> void:
	if is_dead:
		return
	current_health -= amount

	var player: CharacterBody2D = get_player()
	if player != null:
		last_known_position = player.global_position
		become_alerted(true)
		if player.has_method("freeze_frame"):
			player.call("freeze_frame", 0.08)
		if player.has_method("shake_camera"):
			player.call("shake_camera", 8.0, 6.0)
		var knockback_direction: Vector2 = (global_position - player.global_position).normalized()
		knockback_velocity = knockback_direction * 1000.0

	color_rect.color = FLASH_COLOR
	await get_tree().create_timer(0.08).timeout
	color_rect.color = default_color

	if current_health <= 0:
		die()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	var level: Node = get_parent()
	if persistent_guard and level.has_method("register_guard_defeat"):
		level.call("register_guard_defeat", str(name))
	else:
		Global.record_guard_defeat()
	if level.has_method("add_score"):
		level.call("add_score", 1)
	color_rect.visible = false
	vision_cone.visible = false
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)
	bark_label.visible = false
	awareness_label.visible = false
	queue_free()

func start_attack_routine(attack_direction: Vector2) -> void:
	if is_attacking or is_dead:
		return
	is_attacking = true
	attack_cooldown_timer = ATTACK_COOLDOWN
	shout_dialogue("À mort!")
	color_rect.color = Color.YELLOW
	await get_tree().create_timer(0.4).timeout
	if is_dead:
		return
	color_rect.color = default_color
	hitbox.position = attack_direction * 25.0
	hitbox.rotation = attack_direction.angle()
	hitbox.visible = true
	hitbox.monitoring = true
	hitbox.monitorable = true
	await get_tree().create_timer(0.15).timeout
	hitbox.visible = false
	hitbox.monitoring = false
	hitbox.monitorable = false
	is_attacking = false
