extends Node2D

@export_enum("street", "workshop", "printshop") var sector_id: String = "street"
@export var room_size: Vector2i = Vector2i(1200, 700)

const STREET_PATROL_A: Array[Vector2] = [Vector2(180, 180), Vector2(520, 180), Vector2(520, 500), Vector2(180, 500)]
const STREET_PATROL_B: Array[Vector2] = [Vector2(720, 500), Vector2(1050, 500), Vector2(1050, 190), Vector2(720, 190)]
const WORKSHOP_PATROL_A: Array[Vector2] = [Vector2(170, 180), Vector2(500, 180), Vector2(500, 520), Vector2(170, 520)]
const WORKSHOP_PATROL_B: Array[Vector2] = [Vector2(650, 170), Vector2(900, 170), Vector2(900, 500), Vector2(650, 500)]
const PRINTSHOP_PATROL_A: Array[Vector2] = [Vector2(180, 170), Vector2(520, 170), Vector2(520, 510), Vector2(180, 510)]
const PRINTSHOP_PATROL_B: Array[Vector2] = [Vector2(680, 180), Vector2(1030, 180), Vector2(1030, 510), Vector2(680, 510)]

func _ready() -> void:
	configure_guards()
	Global.position_player_at_pending_spawn(self)
	configure_camera_limits()
	show_arrival_message.call_deferred()

func configure_guards() -> void:
	if sector_id == "street":
		assign_patrol(get_node_or_null("GuardStreetA"), STREET_PATROL_A)
		assign_patrol(get_node_or_null("GuardStreetB"), STREET_PATROL_B)
	elif sector_id == "workshop":
		assign_patrol(get_node_or_null("GuardWorkshopA"), WORKSHOP_PATROL_A)
		assign_patrol(get_node_or_null("GuardWorkshopB"), WORKSHOP_PATROL_B)
	else:
		if Global.current_quest not in [Global.QUEST_REACH_PRINTSHOP, Global.QUEST_ESCAPE_SAINT_ANTOINE]:
			remove_guard(get_node_or_null("GuardRaidA"))
			remove_guard(get_node_or_null("GuardRaidB"))
			remove_guard(get_node_or_null("GuardRaidC"))
			return
		assign_patrol(get_node_or_null("GuardRaidA"), PRINTSHOP_PATROL_A)
		assign_patrol(get_node_or_null("GuardRaidB"), PRINTSHOP_PATROL_B)

func remove_guard(guard: Node) -> void:
	if guard != null:
		guard.process_mode = Node.PROCESS_MODE_DISABLED
		guard.queue_free()

func show_arrival_message() -> void:
	await get_tree().process_frame
	var hud_nodes: Array[Node] = get_tree().get_nodes_in_group("run_hud")
	if hud_nodes.is_empty() or not hud_nodes[0].has_method("show_message"):
		return
	if sector_id == "street" and Global.current_quest == Global.QUEST_MEET_LUCILE:
		hud_nodes[0].call("show_message", "Étienne", "Silk, perfume, polished cane. In Saint-Antoine, every part of me arrives before I do. Lucile works among the cabinetmakers.", 6.5)
	elif sector_id == "workshop" and Global.current_quest == Global.QUEST_SEARCH_WORKSHOP:
		hud_nodes[0].call("show_message", "Étienne", "The shutters are old. The sawdust is not. Someone crossed this abandoned room recently and wanted it to look untouched.", 6.5)
	elif sector_id == "printshop" and Global.current_quest == Global.QUEST_REACH_PRINTSHOP:
		hud_nodes[0].call("show_message", "Police captain", "Seal both courtyards. Take the presses, the names, and anyone whose hands smell of ink!", 6.5)

func assign_patrol(guard: Node, route_points: Array[Vector2]) -> void:
	if guard != null and guard.has_method("set_patrol_route"):
		guard.call("set_patrol_route", route_points)

func register_detection() -> void:
	Global.exposure += 1
	Global.save_game()

func register_guard_defeat(_guard_id: String) -> void:
	Global.record_guard_defeat()
	Global.save_game()

func configure_camera_limits() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player: Node = players[0]
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = room_size.x
	camera.limit_bottom = room_size.y
	camera.limit_smoothed = true