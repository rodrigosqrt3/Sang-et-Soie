extends Area2D

@onready var shade: ColorRect = $Shade

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("enter_hiding_zone"):
		body.call("enter_hiding_zone")
	shade.modulate = Color(0.82, 0.9, 0.86, 1.0)

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("exit_hiding_zone"):
		body.call("exit_hiding_zone")
	shade.modulate = Color.WHITE