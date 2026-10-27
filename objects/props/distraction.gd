extends Node2D

const FLIGHT_DURATION: float = 0.34
const ARC_HEIGHT: float = 38.0

var start_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var elapsed_time: float = 0.0
var configured: bool = false
var has_landed: bool = false

@onready var coin_visual: ColorRect = $CoinVisual
@onready var noise_ring: Line2D = $NoiseRing
@onready var sound_label: Label = $SoundLabel

func _ready() -> void:
	noise_ring.visible = false
	sound_label.visible = false

func setup(origin: Vector2, destination: Vector2) -> void:
	start_position = origin
	target_position = destination
	global_position = origin
	configured = true

func _process(delta: float) -> void:
	if not configured or has_landed:
		return

	elapsed_time += delta
	var progress: float = minf(1.0, elapsed_time / FLIGHT_DURATION)
	global_position = start_position.lerp(target_position, progress)
	global_position.y -= sin(progress * PI) * ARC_HEIGHT
	coin_visual.rotation = progress * PI * 5.0

	if progress >= 1.0:
		land()

func land() -> void:
	if has_landed:
		return
	has_landed = true
	global_position = target_position
	coin_visual.visible = false
	noise_ring.visible = true
	sound_label.visible = true
	get_tree().call_group("enemies", "hear_distraction", global_position)

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(noise_ring, "scale", Vector2(3.2, 3.2), 0.65)
	tween.tween_property(noise_ring, "modulate:a", 0.0, 0.65)
	tween.tween_property(sound_label, "modulate:a", 0.0, 0.65)
	await tween.finished
	queue_free()