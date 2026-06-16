extends StaticBody2D

# Preload the Champagne scene to spawn it when broken
const CHAMPAGNE_SCENE = preload("res://champagne.tscn")

# 30% chance to drop Champagne
const DROP_CHANCE: float = 0.30

# References to nodes
@onready var hurtbox: Area2D = $Hurtbox
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	# Connect the Hurtbox to detect when the player's weapon hits the crate
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	# If hit by the player's AttackArea, break the crate!
	if area.name == "AttackArea":
		break_crate()

func break_crate() -> void:
	print("Crate smashed!")
	
	# Play a subtle Hit-Stop effect on the player's screen for impact
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as CharacterBody2D
		if player.has_method("freeze_frame"):
			player.freeze_frame(0.05) # Tiny freeze of 50ms
		if player.has_method("shake_camera"):
			player.shake_camera(6.0, 6.0)
	
	# Sorteio de probabilidade: drop Champagne
	if randf() < DROP_CHANCE:
		spawn_champagne()
		
	# Destroy the crate immediately
	queue_free()

func spawn_champagne() -> void:
	var champagne_instance = CHAMPAGNE_SCENE.instantiate() as Area2D
	# Spawn exactly where the crate was located
	champagne_instance.global_position = global_position
	get_parent().add_child(champagne_instance)
	print("Champagne bottle found inside the crate!")
