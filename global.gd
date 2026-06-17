extends Node

# Persistent RPG variables
var runs_completed: int = 0
var francs: int = 0 

# Player Stats
var dash_cooldown: float = 1.0      
var weapon_scale: Vector2 = Vector2(1.0, 1.0) 

# ADD: The active quest state ("talk_to_smuggler", "enter_streets", "report_to_smuggler", "talk_to_marguerite")
var current_quest: String = "talk_to_smuggler"