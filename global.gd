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

# Player Stats (saved permanently across runs)
var dash_cooldown: float = 1.0      
var weapon_scale: Vector2 = Vector2(1.0, 1.0) 
var focus_drain_rate: float = 60.0 # Base focus drain per second. Can be upgraded to 35.0

# The active quest state
var current_quest: String = "talk_to_smuggler"

# OS-independent safe path for save data
const SAVE_PATH = "user://save_game.cfg"
const DEVELOPMENT_MODE: bool = true

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
	dash_cooldown = 1.0
	weapon_scale = Vector2(1.0, 1.0)
	focus_drain_rate = 60.0
	current_quest = "talk_to_smuggler"

func record_guard_defeat() -> void:
	violence += 1
	exposure += 1

func record_failed_run() -> void:
	failed_runs += 1
	exposure += 1
	if current_quest == "enter_streets":
		has_list_fragment = false
		fragment_recovered_without_killing = false
	save_game()

func save_game() -> void:
	if DEVELOPMENT_MODE:
		return

	var config = ConfigFile.new()
	
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
	
	config.set_value("upgrades", "dash_cooldown", dash_cooldown)
	config.set_value("upgrades", "weapon_scale", weapon_scale)
	config.set_value("upgrades", "focus_drain_rate", focus_drain_rate) # NEW: Save focus upgrade
	
	# Write the file to disk
	var err = config.save(SAVE_PATH)
	if err == OK:
		print("Game saved successfully to: ", SAVE_PATH)
	else:
		print("Error saving game: ", err)

func load_game() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
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
		
		dash_cooldown = config.get_value("upgrades", "dash_cooldown", 1.0)
		weapon_scale = config.get_value("upgrades", "weapon_scale", Vector2(1.0, 1.0))
		focus_drain_rate = config.get_value("upgrades", "focus_drain_rate", 60.0) # NEW: Load focus upgrade
		print("Game loaded successfully from disk!")
	else:
		print("No save game found. Starting a fresh campaign.")