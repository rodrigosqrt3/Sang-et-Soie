extends Area2D

func _ready() -> void:
	# Connect the physics signal to detect when a body enters the bottle's area
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	print("DEBUG: Champagne bottle touched by: ", body.name)
	
	if body.is_in_group("player"):
		print("DEBUG: Yes, it is the player!")
		
		if body.has_method("heal"):
			print("DEBUG: Player has the 'heal' function! Drinking...")
			body.heal(1)
			queue_free()
		else:
			print("DEBUG ERROR: Player touched the bottle, but player.gd is missing the 'heal' function!")