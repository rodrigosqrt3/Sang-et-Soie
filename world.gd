extends Node2D

# Global score variable
var score: int = 0

# Reference to the UI label
@onready var score_label: Label = $UI/ScoreLabel

func _ready() -> void:
	# Ensure the UI text starts correctly
	update_score_ui()

# Function called by enemies when they die
func add_score(amount: int) -> void:
	score += amount
	update_score_ui()

# Updates the text shown on screen
func update_score_ui() -> void:
	score_label.text = "Kills: " + str(score)