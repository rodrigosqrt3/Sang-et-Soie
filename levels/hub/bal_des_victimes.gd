extends Node2D

# The hub. Registers the story actions used by the Bal's conversations and
# decides which scene plays when Étienne walks (or is carried) back in.

const JACQUET_ENTRY: Vector2 = Vector2(400, 40)
const JACQUET_FALL: Vector2 = Vector2(400, 178)
const STAIRS_TOP: Vector2 = Vector2(400, 30)

@onready var jacquet: StoryNPC = $Jacquet
@onready var gravelot: StoryNPC = $Gravelot

func _ready() -> void:
	Dialogue.register_action("open_shop", func(_args: Array) -> void: SmugglerShop.open())
	Dialogue.register_action("buy", func(args: Array) -> void: SmugglerShop.buy(str(args[0])))
	Dialogue.register_action("jacquet_enters", _on_jacquet_enters)
	Dialogue.register_action("jacquet_dies", _on_jacquet_dies)
	Dialogue.register_action("gravelot_leaves", _on_gravelot_leaves)
	if not Global.has_flag("prologue_done"):
		# Jacquet only appears when he falls down the stairs.
		jacquet.visible = false
	lock_camera_to_room()
	add_child(ScreenGrade.new())
	play_arrival_scene.call_deferred()

# The Bal fits the screen exactly: the camera never drifts off the room.
func lock_camera_to_room() -> void:
	for player in get_tree().get_nodes_in_group("player"):
		var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
		if camera != null:
			camera.limit_left = 0
			camera.limit_top = 0
			camera.limit_right = 800
			camera.limit_bottom = 600
			camera.position_smoothing_enabled = false
			camera.reset_smoothing()

func play_arrival_scene() -> void:
	# Let the fade-in finish before anyone speaks.
	await get_tree().create_timer(0.45).timeout
	if Dialogue.is_active():
		return
	if not Global.has_flag("prologue_done"):
		Dialogue.start("prologue")
	elif Global.has_flag("pending_recovery_scene"):
		Dialogue.start("recovery")
	elif Global.current_quest == Global.QUEST_CHAPTER_ONE_COMPLETE and not Global.has_flag("seen:chapter_one_close"):
		Dialogue.start("chapter_one_close")
	elif Global.current_quest == Global.QUEST_CHAPTER_TWO_COMPLETE:
		var closing: String = "chapter_two_close_protect" if Global.saint_antoine_raid_choice == "protect_workers" else "chapter_two_close_pursue"
		if not Global.has_flag("seen:" + closing):
			Dialogue.start(closing)

# Tweens here run while the tree is paused by the conversation.
func story_tween() -> Tween:
	return create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

func _on_jacquet_enters(_args: Array) -> void:
	jacquet.visible = true
	jacquet.position = JACQUET_ENTRY
	jacquet.figure.lean = 0.25
	jacquet.figure.moving_ratio = 1.0
	var tween: Tween = story_tween()
	tween.tween_property(jacquet, "position", JACQUET_FALL, 0.9).set_trans(Tween.TRANS_SINE)

func _on_jacquet_dies(_args: Array) -> void:
	jacquet.figure.moving_ratio = 0.0
	var tween: Tween = story_tween()
	tween.tween_property(jacquet.figure, "lean", 1.45, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _on_gravelot_leaves(_args: Array) -> void:
	gravelot.figure.moving_ratio = 0.5
	gravelot.figure.facing_left = gravelot.position.x > STAIRS_TOP.x
	var tween: Tween = story_tween()
	tween.tween_property(gravelot, "position", Vector2(STAIRS_TOP.x, 120), 1.2)
	tween.tween_property(gravelot, "position", STAIRS_TOP, 0.8)
	tween.parallel().tween_property(gravelot, "modulate:a", 0.0, 0.8)
