extends Area2D

@onready var prompt_label: Label = $PromptLabel
var is_player_nearby: bool = false
var collected: bool = false

func _ready() -> void:
	prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if is_player_nearby and not collected and Input.is_action_just_pressed("interact"):
		collect_fragment()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_nearby = false
		prompt_label.visible = false

func collect_fragment() -> void:
	collected = true
	monitoring = false
	prompt_label.visible = false

	var world: Node = get_parent()
	if world.has_method("collect_list_fragment"):
		world.call("collect_list_fragment")

	queue_free()