extends Node2D

@onready var color_rect: ColorRect = $ColorRect
@onready var entry_label: Label = $EntryLabel

var elapsed_time: float = 0.0
const BLINK_SPEED: float = 25.0 # Frequency of the pulse

func _process(delta: float) -> void:
	elapsed_time += delta
	
	# A short glint at an entrance reads as approaching footsteps, not a magical spawn tile.
	var pulse: float = (sin(elapsed_time * BLINK_SPEED) + 1.0) * 0.5
	color_rect.color.a = 0.18 + pulse * 0.55
	color_rect.scale.x = 0.75 + pulse * 0.35
	entry_label.modulate.a = 0.35 + pulse * 0.65