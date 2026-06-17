extends Node2D

@onready var objective_label: Label = $UI/ObjectiveLabel

func _ready() -> void:
	update_objective_ui()

func _process(_delta: float) -> void:
	# Keep updating the UI text in real-time as the quest state changes
	update_objective_ui()

func update_objective_ui() -> void:
	if Global.current_quest == "talk_to_smuggler":
		objective_label.text = "Objective: Talk to the Belgian Smuggler about Théodore"
	elif Global.current_quest == "enter_streets":
		objective_label.text = "Objective: Enter the golden door to clear the streets"
	elif Global.current_quest == "report_to_smuggler":
		objective_label.text = "Objective: Report back to the Smuggler"
	elif Global.current_quest == "talk_to_marguerite":
		objective_label.text = "Objective: Ask Marguerite about the sewer gate"