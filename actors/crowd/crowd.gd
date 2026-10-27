extends Node2D

@export var roam_extents: Vector2 = Vector2(90.0, 42.0)
@export var movement_speed: float = 24.0
@export var acceleration: float = 42.0
@export var pause_min: float = 0.7
@export var pause_max: float = 2.4

const MEMBER_ROAM_X: float = 22.0
const MEMBER_ROAM_Y: float = 13.0
const MEMBER_MIN_SEPARATION: float = 25.0
const MEMBER_ACCELERATION: float = 70.0

var origin_position: Vector2 = Vector2.ZERO
var group_destination: Vector2 = Vector2.ZERO
var group_velocity: Vector2 = Vector2.ZERO
var group_pause_timer: float = 0.0
var disturbed: bool = false
var base_movement_speed: float = 0.0
var base_acceleration: float = 0.0
var base_pause_min: float = 0.0
var base_pause_max: float = 0.0
var base_roam_extents: Vector2 = Vector2.ZERO

var members: Array[Node2D] = []
var member_home_positions: Array[Vector2] = []
var member_targets: Array[Vector2] = []
var member_velocities: Array[Vector2] = []
var member_speeds: Array[float] = []
var member_wait_timers: Array[float] = []

@onready var figures: Node2D = $Figures
@onready var blend_area: Area2D = $BlendArea

func _ready() -> void:
	add_to_group("crowds")
	base_movement_speed = movement_speed
	base_acceleration = acceleration
	base_pause_min = pause_min
	base_pause_max = pause_max
	base_roam_extents = roam_extents
	origin_position = position
	group_destination = position
	group_pause_timer = randf_range(0.2, 1.2)
	blend_area.body_entered.connect(_on_body_entered)
	blend_area.body_exited.connect(_on_body_exited)
	register_members()

func set_disturbed(value: bool) -> void:
	if disturbed == value:
		return
	disturbed = value
	if disturbed:
		movement_speed = base_movement_speed * 2.25
		acceleration = base_acceleration * 1.8
		pause_min = 0.05
		pause_max = 0.28
		roam_extents = base_roam_extents * 1.45
		figures.modulate = Color(1.0, 0.78, 0.72, 0.78)
		blend_area.set_deferred("monitoring", false)
		blend_area.set_deferred("monitorable", false)
		force_player_out_of_blend()
		for member_index in range(member_speeds.size()):
			member_speeds[member_index] = randf_range(30.0, 48.0)
			member_wait_timers[member_index] = randf_range(0.0, 0.15)
			choose_member_target(member_index)
		group_pause_timer = 0.0
		choose_group_destination()
	else:
		movement_speed = base_movement_speed
		acceleration = base_acceleration
		pause_min = base_pause_min
		pause_max = base_pause_max
		roam_extents = base_roam_extents
		figures.modulate = Color.WHITE
		blend_area.set_deferred("monitoring", true)
		blend_area.set_deferred("monitorable", true)

func force_player_out_of_blend() -> void:
	var overlapping_bodies: Array[Node2D] = blend_area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("player") and body.has_method("exit_social_blend"):
			body.call("exit_social_blend")

func register_members() -> void:
	var figure_nodes: Array[Node] = figures.get_children()
	for figure_node in figure_nodes:
		var member: Node2D = figure_node as Node2D
		if member == null:
			continue
		members.append(member)
		member_home_positions.append(member.position)
		member_targets.append(member.position)
		member_velocities.append(Vector2.ZERO)
		member_speeds.append(randf_range(13.0, 25.0))
		member_wait_timers.append(randf_range(0.0, 1.4))

func _process(delta: float) -> void:
	update_group_movement(delta)
	update_member_movement(delta)

func update_group_movement(delta: float) -> void:
	if group_pause_timer > 0.0:
		group_pause_timer = maxf(0.0, group_pause_timer - delta)
		group_velocity = group_velocity.move_toward(Vector2.ZERO, acceleration * delta)
		position += group_velocity * delta
		if group_pause_timer <= 0.0:
			choose_group_destination()
		return

	var to_destination: Vector2 = group_destination - position
	if to_destination.length() <= 7.0:
		group_pause_timer = randf_range(pause_min, pause_max)
		return

	var desired_velocity: Vector2 = to_destination.normalized() * movement_speed
	group_velocity = group_velocity.move_toward(desired_velocity, acceleration * delta)
	position += group_velocity * delta

func choose_group_destination() -> void:
	var destination_offset: Vector2 = Vector2(
		randf_range(-roam_extents.x, roam_extents.x),
		randf_range(-roam_extents.y, roam_extents.y)
	)
	if disturbed and destination_offset.length_squared() > 0.01:
		destination_offset = destination_offset.normalized() * Vector2(
			roam_extents.x,
			roam_extents.y
		).length() * randf_range(0.72, 1.0)
	group_destination = origin_position + destination_offset

func update_member_movement(delta: float) -> void:
	for member_index in range(members.size()):
		var member: Node2D = members[member_index]
		if member_wait_timers[member_index] > 0.0:
			member_wait_timers[member_index] = maxf(0.0, member_wait_timers[member_index] - delta)
			member_velocities[member_index] = member_velocities[member_index].move_toward(
				Vector2.ZERO,
				MEMBER_ACCELERATION * delta
			)
		else:
			update_active_member(member_index, delta)

		member.position += member_velocities[member_index] * delta
		member.rotation = clampf(member_velocities[member_index].x / 500.0, -0.045, 0.045)

func update_active_member(member_index: int, delta: float) -> void:
	var member: Node2D = members[member_index]
	var to_target: Vector2 = member_targets[member_index] - member.position
	if to_target.length() <= 3.0:
		member_wait_timers[member_index] = randf_range(0.35, 1.8)
		choose_member_target(member_index)
		return

	var desired_velocity: Vector2 = to_target.normalized() * member_speeds[member_index]
	desired_velocity += calculate_separation(member_index)
	member_velocities[member_index] = member_velocities[member_index].move_toward(
		desired_velocity,
		MEMBER_ACCELERATION * delta
	)

func choose_member_target(member_index: int) -> void:
	var roam_multiplier: float = 2.1 if disturbed else 1.0
	member_targets[member_index] = member_home_positions[member_index] + Vector2(
		randf_range(-MEMBER_ROAM_X, MEMBER_ROAM_X) * roam_multiplier,
		randf_range(-MEMBER_ROAM_Y, MEMBER_ROAM_Y) * roam_multiplier
	)

func calculate_separation(member_index: int) -> Vector2:
	var separation: Vector2 = Vector2.ZERO
	var member: Node2D = members[member_index]
	for other_index in range(members.size()):
		if other_index == member_index:
			continue
		var difference: Vector2 = member.position - members[other_index].position
		var distance: float = difference.length()
		if distance > 0.01 and distance < MEMBER_MIN_SEPARATION:
			separation += difference.normalized() * (MEMBER_MIN_SEPARATION - distance) * 2.8
	return separation

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("enter_social_blend"):
		body.call("enter_social_blend")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("exit_social_blend"):
		body.call("exit_social_blend")