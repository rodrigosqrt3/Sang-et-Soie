extends Node

# Persistent RPG variables
var runs_completed: int = 0
var francs: int = 0 

# Player Stats (saved permanently across runs)
var dash_cooldown: float = 1.0      
var weapon_scale: Vector2 = Vector2(1.0, 1.0) 

# The active quest state
var current_quest: String = "talk_to_smuggler"

# OS-independent safe path for save data
const SAVE_PATH = "user://save_game.cfg"

func _ready() -> void:
	# load_game()
	pass

func save_game() -> void:
	var config = ConfigFile.new()
	
	# Save variables into sections and keys inside the .cfg file
	config.set_value("progression", "runs_completed", runs_completed)
	config.set_value("progression", "francs", francs)
	config.set_value("progression", "current_quest", current_quest)
	
	config.set_value("upgrades", "dash_cooldown", dash_cooldown)
	config.set_value("upgrades", "weapon_scale", weapon_scale)
	
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
		francs = config.get_value("progression", "francs", 0)
		current_quest = config.get_value("progression", "current_quest", "talk_to_smuggler")
		
		dash_cooldown = config.get_value("upgrades", "dash_cooldown", 1.0)
		weapon_scale = config.get_value("upgrades", "weapon_scale", Vector2(1.0, 1.0))
		print("Game loaded successfully from disk!")
	else:
		print("No save game found. Starting a fresh campaign.")