extends StaticBody2D

const CHAMPAGNE_SCENE: PackedScene = preload("res://objects/props/champagne.tscn")
const DROP_CHANCE: float = 0.30

@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	$ColorRect.visible = false
	PropArt.attach(self, "crate")

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		break_crate()

func break_crate() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		var player: CharacterBody2D = players[0] as CharacterBody2D
		if player != null:
			if player.has_method("freeze_frame"):
				player.call("freeze_frame", 0.05)
			if player.has_method("shake_camera"):
				player.call("shake_camera", 6.0, 6.0)

	if randf() < DROP_CHANCE:
		spawn_champagne()
	queue_free()

func spawn_champagne() -> void:
	var champagne_instance: Area2D = CHAMPAGNE_SCENE.instantiate() as Area2D
	if champagne_instance == null:
		return
	champagne_instance.global_position = global_position
	get_parent().add_child.call_deferred(champagne_instance)