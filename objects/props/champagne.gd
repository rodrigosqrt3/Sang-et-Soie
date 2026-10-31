extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$ColorRect.visible = false
	PropArt.attach(self, "champagne")

# The bottle stays on the floor if Étienne is already unhurt.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("heal"):
		if bool(body.call("heal", 1)):
			queue_free()
