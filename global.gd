extends Node

# Persistent RPG variables
var runs_completed: int = 0
var failed_runs: int = 0
var francs: int = 0 

# Narrative consequences saved across excursions.
var violence: int = 0
var exposure: int = 0
var smuggler_trust: int = 0
var smuggler_debt: int = 0
var has_list_fragment: bool = false
var fragment_recovered_without_killing: bool = false
var theodore_knows_about_lists: bool = false

# World navigation state. Shortcuts persist; pending spawn exists only while
# moving between two connected scenes.
var unlocked_shortcuts: Dictionary = {}
var pending_spawn_id: String = ""

# Temporary state shared by every room of the Palais-Royal excursion.
# Keeping it here prevents violence and detection from being forgotten when
# Étienne crosses into another arcade.
var palais_run_violence: int = 0
var palais_run_detected: bool = false
var palais_global_alert: int = 0
var palais_sector_states: Dictionary = {}
var palais_fragment_spot_index: int = -1

# Volatile state for the player during a single excursion. Every district scene
# creates a fresh Player node, so these values carry injuries and spent tools
# across room transitions without making them permanent upgrades.
var active_run: bool = false
var run_health: int = 3
var run_focus: float = 100.0
var run_distraction_charges: int = 3

const PALAIS_SECTOR_NEIGHBORS: Dictionary = {
	"garden": ["west", "east"],
	"west": ["garden", "east"],
	"east": ["garden", "west"]
}

# Player Stats (saved permanently across runs)
var dash_cooldown: float = 1.0      
var weapon_scale: Vector2 = Vector2(1.0, 1.0) 
var focus_drain_rate: float = 60.0 # Base focus drain per second. Can be upgraded to 35.0

# The active quest state
var current_quest: String = "talk_to_smuggler"

# OS-independent safe path for save data
const SAVE_PATH = "user://save_game.cfg"
const DEVELOPMENT_MODE: bool = false

func _ready() -> void:
	if DEVELOPMENT_MODE:
		reset_progress()
		var old_save_path: String = ProjectSettings.globalize_path(SAVE_PATH)
		if FileAccess.file_exists(SAVE_PATH):
			DirAccess.remove_absolute(old_save_path)
		print("Development mode: progress reset and disk saving disabled.")
	else:
		load_game()

func reset_progress() -> void:
	runs_completed = 0
	failed_runs = 0
	francs = 0
	violence = 0
	exposure = 0
	smuggler_trust = 0
	smuggler_debt = 0
	has_list_fragment = false
	fragment_recovered_without_killing = false
	theodore_knows_about_lists = false
	unlocked_shortcuts.clear()
	pending_spawn_id = ""
	palais_run_violence = 0
	palais_run_detected = false
	palais_global_alert = 0
	palais_sector_states.clear()
	palais_fragment_spot_index = -1
	reset_active_run_state()
	dash_cooldown = 1.0
	weapon_scale = Vector2(1.0, 1.0)
	focus_drain_rate = 60.0
	current_quest = "talk_to_smuggler"

func record_guard_defeat() -> void:
	violence += 1
	exposure += 1
	if current_quest == "enter_streets":
		palais_run_violence += 1

func begin_palais_excursion() -> void:
	palais_run_violence = 0
	palais_run_detected = false
	palais_global_alert = 0
	palais_sector_states.clear()
	palais_fragment_spot_index = -1
	has_list_fragment = false
	fragment_recovered_without_killing = false
	begin_active_run()

func begin_active_run() -> void:
	active_run = true
	run_health = 3
	run_focus = 100.0
	run_distraction_charges = 3

func reset_active_run_state() -> void:
	active_run = false
	run_health = 3
	run_focus = 100.0
	run_distraction_charges = 3

func capture_player_run_state(player: Node) -> void:
	if not active_run or player == null or bool(player.get("is_safe_mode")):
		return
	run_health = clampi(int(player.get("current_health")), 0, 3)
	run_focus = clampf(float(player.get("current_focus")), 0.0, 100.0)
	run_distraction_charges = clampi(int(player.get("distraction_charges")), 0, 3)

func restore_player_run_state(player: Node) -> void:
	if not active_run or player == null or bool(player.get("is_safe_mode")):
		return
	player.set("current_health", run_health)
	player.set("current_focus", run_focus)
	player.set("distraction_charges", run_distraction_charges)

func choose_palais_fragment_spot(spot_count: int) -> int:
	if spot_count <= 0:
		return 0
	if palais_fragment_spot_index < 0 or palais_fragment_spot_index >= spot_count:
		palais_fragment_spot_index = randi_range(0, spot_count - 1)
		save_game()
	return palais_fragment_spot_index

func ensure_palais_sector_state(sector_id: String) -> Dictionary:
	if not palais_sector_states.has(sector_id):
		palais_sector_states[sector_id] = {
			"defeated_guards": [],
			"alert_level": 0,
			"crowd_disturbed": false,
			"visits": 0
		}
	return palais_sector_states[sector_id] as Dictionary

func register_palais_sector_visit(sector_id: String) -> int:
	var state: Dictionary = ensure_palais_sector_state(sector_id)
	var visits: int = int(state.get("visits", 0)) + 1
	state["visits"] = visits
	palais_sector_states[sector_id] = state
	return visits

func get_palais_sector_alert(sector_id: String) -> int:
	var state: Dictionary = ensure_palais_sector_state(sector_id)
	return int(state.get("alert_level", 0))

func is_palais_crowd_disturbed(sector_id: String) -> bool:
	var state: Dictionary = ensure_palais_sector_state(sector_id)
	return bool(state.get("crowd_disturbed", false))

func is_palais_guard_defeated(sector_id: String, guard_id: String) -> bool:
	var state: Dictionary = ensure_palais_sector_state(sector_id)
	var defeated_guards: Array = state.get("defeated_guards", []) as Array
	return defeated_guards.has(guard_id)

func mark_palais_guard_defeated(sector_id: String, guard_id: String) -> void:
	var state: Dictionary = ensure_palais_sector_state(sector_id)
	var defeated_guards: Array = state.get("defeated_guards", []) as Array
	if defeated_guards.has(guard_id):
		return
	defeated_guards.append(guard_id)
	state["defeated_guards"] = defeated_guards
	state["crowd_disturbed"] = true
	state["alert_level"] = maxi(2, int(state.get("alert_level", 0)))
	palais_sector_states[sector_id] = state
	record_guard_defeat()
	raise_palais_alert(sector_id)
	save_game()

func raise_palais_alert(source_sector: String) -> void:
	palais_global_alert = maxi(palais_global_alert, 2)
	var source_state: Dictionary = ensure_palais_sector_state(source_sector)
	source_state["alert_level"] = 2
	source_state["crowd_disturbed"] = true
	palais_sector_states[source_sector] = source_state

	var neighbors: Array = PALAIS_SECTOR_NEIGHBORS.get(source_sector, []) as Array
	for neighbor_value in neighbors:
		var neighbor_id: String = str(neighbor_value)
		var neighbor_state: Dictionary = ensure_palais_sector_state(neighbor_id)
		neighbor_state["alert_level"] = maxi(1, int(neighbor_state.get("alert_level", 0)))
		palais_sector_states[neighbor_id] = neighbor_state

func register_palais_detection(source_sector: String = "garden") -> bool:
	if current_quest != "enter_streets":
		return false
	raise_palais_alert(source_sector)
	if palais_run_detected:
		save_game()
		return false
	palais_run_detected = true
	exposure += 1
	save_game()
	return true

func record_failed_run() -> void:
	failed_runs += 1
	exposure += 1
	if current_quest == "enter_streets":
		has_list_fragment = false
		fragment_recovered_without_killing = false
		palais_run_violence = 0
		palais_run_detected = false
		palais_global_alert = 0
		palais_sector_states.clear()
		palais_fragment_spot_index = -1
	reset_active_run_state()
	save_game()

func unlock_shortcut(shortcut_id: String) -> void:
	if shortcut_id.is_empty() or is_shortcut_unlocked(shortcut_id):
		return
	unlocked_shortcuts[shortcut_id] = true
	print("Shortcut unlocked: ", shortcut_id)
	save_game()

func is_shortcut_unlocked(shortcut_id: String) -> bool:
	if shortcut_id.is_empty():
		return true
	return bool(unlocked_shortcuts.get(shortcut_id, false))

func travel_to_scene(destination_scene: String, spawn_id: String) -> void:
	if destination_scene.is_empty():
		push_error("A district passage has no destination scene.")
		return
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		capture_player_run_state(players[0])
	pending_spawn_id = spawn_id
	save_game()
	get_tree().change_scene_to_file.call_deferred(destination_scene)

func position_player_at_pending_spawn(scene_root: Node) -> void:
	if pending_spawn_id.is_empty():
		return

	var arrival_points: Array[Node] = get_tree().get_nodes_in_group("arrival_points")
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	var player: Node2D = players[0] as Node2D
	if player == null:
		return

	for arrival_node in arrival_points:
		if not scene_root.is_ancestor_of(arrival_node):
			continue
		var arrival_id: String = str(arrival_node.get("spawn_id"))
		if arrival_id == pending_spawn_id:
			var arrival_point: Node2D = arrival_node as Node2D
			if arrival_point != null:
				player.global_position = arrival_point.global_position
				pending_spawn_id = ""
				return

	push_warning("Arrival point not found: " + pending_spawn_id)
	pending_spawn_id = ""

func save_game() -> void:
	if DEVELOPMENT_MODE:
		return

	var config: ConfigFile = ConfigFile.new()
	
	# Save variables into sections and keys inside the .cfg file
	config.set_value("progression", "runs_completed", runs_completed)
	config.set_value("progression", "failed_runs", failed_runs)
	config.set_value("progression", "francs", francs)
	config.set_value("progression", "current_quest", current_quest)
	config.set_value("consequences", "violence", violence)
	config.set_value("consequences", "exposure", exposure)
	config.set_value("consequences", "smuggler_trust", smuggler_trust)
	config.set_value("consequences", "smuggler_debt", smuggler_debt)
	config.set_value("consequences", "has_list_fragment", has_list_fragment)
	config.set_value("consequences", "fragment_recovered_without_killing", fragment_recovered_without_killing)
	config.set_value("consequences", "theodore_knows_about_lists", theodore_knows_about_lists)
	config.set_value("navigation", "unlocked_shortcuts", unlocked_shortcuts)
	config.set_value("navigation", "palais_run_violence", palais_run_violence)
	config.set_value("navigation", "palais_run_detected", palais_run_detected)
	config.set_value("navigation", "palais_global_alert", palais_global_alert)
	config.set_value("navigation", "palais_sector_states", palais_sector_states)
	config.set_value("navigation", "palais_fragment_spot_index", palais_fragment_spot_index)
	config.set_value("run", "active", active_run)
	config.set_value("run", "health", run_health)
	config.set_value("run", "focus", run_focus)
	config.set_value("run", "distraction_charges", run_distraction_charges)
	
	config.set_value("upgrades", "dash_cooldown", dash_cooldown)
	config.set_value("upgrades", "weapon_scale", weapon_scale)
	config.set_value("upgrades", "focus_drain_rate", focus_drain_rate) # NEW: Save focus upgrade
	
	# Write the file to disk
	var err: Error = config.save(SAVE_PATH)
	if err == OK:
		print("Game saved successfully to: ", SAVE_PATH)
	else:
		print("Error saving game: ", err)

func load_game() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(SAVE_PATH)
	
	# If the save file exists, read and restore all variables on startup
	if err == OK:
		runs_completed = config.get_value("progression", "runs_completed", 0)
		failed_runs = config.get_value("progression", "failed_runs", 0)
		francs = config.get_value("progression", "francs", 0)
		current_quest = config.get_value("progression", "current_quest", "talk_to_smuggler")

		if current_quest == "report_to_smuggler":
			current_quest = "report_fragment"

		violence = config.get_value("consequences", "violence", 0)
		exposure = config.get_value("consequences", "exposure", 0)
		smuggler_trust = config.get_value("consequences", "smuggler_trust", 0)
		smuggler_debt = config.get_value("consequences", "smuggler_debt", 0)
		has_list_fragment = config.get_value("consequences", "has_list_fragment", false)
		fragment_recovered_without_killing = config.get_value("consequences", "fragment_recovered_without_killing", false)
		theodore_knows_about_lists = config.get_value("consequences", "theodore_knows_about_lists", false)
		unlocked_shortcuts = config.get_value("navigation", "unlocked_shortcuts", {}) as Dictionary
		palais_run_violence = int(config.get_value("navigation", "palais_run_violence", 0))
		palais_run_detected = bool(config.get_value("navigation", "palais_run_detected", false))
		palais_global_alert = int(config.get_value("navigation", "palais_global_alert", 0))
		palais_sector_states = config.get_value("navigation", "palais_sector_states", {}) as Dictionary
		palais_fragment_spot_index = int(config.get_value("navigation", "palais_fragment_spot_index", -1))
		active_run = bool(config.get_value("run", "active", false))
		run_health = int(config.get_value("run", "health", 3))
		run_focus = float(config.get_value("run", "focus", 100.0))
		run_distraction_charges = int(config.get_value("run", "distraction_charges", 3))
		
		dash_cooldown = config.get_value("upgrades", "dash_cooldown", 1.0)
		weapon_scale = config.get_value("upgrades", "weapon_scale", Vector2(1.0, 1.0))
		focus_drain_rate = config.get_value("upgrades", "focus_drain_rate", 60.0) # NEW: Load focus upgrade
		print("Game loaded successfully from disk!")
	else:
		print("No save game found. Starting a fresh campaign.")