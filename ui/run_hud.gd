extends CanvasLayer

@export var area_title: String = "PARIS"

var message_time_remaining: float = 0.0

@onready var title_label: Label = $TitleLabel
@onready var objective_label: Label = $ObjectiveLabel
@onready var health_bar: ProgressBar = $HealthBar
@onready var dash_bar: ProgressBar = $DashBar
@onready var focus_bar: ProgressBar = $FocusBar
@onready var tools_label: Label = $ToolsLabel
@onready var consequence_label: Label = $ConsequenceLabel
@onready var monocle_filter: ColorRect = $MonocleFilter
@onready var message_panel: ColorRect = $MessagePanel
@onready var speaker_label: Label = $MessagePanel/SpeakerLabel
@onready var message_label: Label = $MessagePanel/MessageLabel

func _ready() -> void:
	add_to_group("run_hud")
	title_label.text = area_title
	message_panel.visible = false
	refresh_objective()

func _process(delta: float) -> void:
	refresh_objective()
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		var player: Node = players[0]
		health_bar.value = float(player.get("current_health"))
		focus_bar.value = float(player.get("current_focus"))
		var cooldown_timer: float = float(player.get("dash_cooldown_timer"))
		dash_bar.value = clampf((Global.dash_cooldown - cooldown_timer) / Global.dash_cooldown * 100.0, 0.0, 100.0)
		tools_label.text = "COINS [Q]: " + str(int(player.get("distraction_charges"))) + "  ·  LE REGARD [RMB]"
		var using_monocle: bool = bool(player.get("is_using_monocle"))
		var target_alpha: float = 0.40 if using_monocle else 0.0
		monocle_filter.color.a = move_toward(monocle_filter.color.a, target_alpha, delta * 4.0)

	consequence_label.text = "EXPOSURE " + str(Global.exposure) + "  ·  VIOLENCE " + str(Global.violence)
	if message_time_remaining > 0.0:
		message_time_remaining -= delta
		if message_time_remaining <= 0.0:
			message_panel.visible = false

func refresh_objective() -> void:
	objective_label.text = "OBJECTIVE: " + Global.get_current_objective()

func show_message(speaker: String, message: String, duration: float = 6.0) -> void:
	speaker_label.text = speaker
	message_label.text = message
	message_panel.visible = true
	message_time_remaining = duration
