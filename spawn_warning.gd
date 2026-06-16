extends Node2D

@onready var color_rect: ColorRect = $ColorRect

var elapsed_time: float = 0.0
const BLINK_SPEED: float = 25.0 # Frequency of the pulse

func _process(delta: float) -> void:
	elapsed_time += delta
	
	# Mathematical pulse: oscillates opacity smoothly between 0.1 and 0.6 using a sine wave
	color_rect.color.a = 0.1 + (sin(elapsed_time * BLINK_SPEED) + 1.0) / 2.0 * 0.5