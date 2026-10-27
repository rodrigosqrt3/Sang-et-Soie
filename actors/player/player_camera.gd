extends Camera2D

# Current intensity of the shake
var shake_strength: float = 0.0
# How fast the shake fades away over time
var shake_decay: float = 5.0

func _process(delta: float) -> void:
	# If there is active shake strength, apply random offsets
	if shake_strength > 0.1:
		var offset_x = randf_range(-shake_strength, shake_strength)
		var offset_y = randf_range(-shake_strength, shake_strength)
		offset = Vector2(offset_x, offset_y)
		
		# Smoothly decay the shake strength towards 0.0 using delta
		shake_strength = move_toward(shake_strength, 0.0, shake_decay * delta * 100.0)
	else:
		# Reset offset to normal when the shake is done
		offset = Vector2.ZERO

# Public function that the player can call to trigger a camera shake
func apply_shake(strength: float, decay: float = 5.0) -> void:
	shake_strength = strength
	shake_decay = decay