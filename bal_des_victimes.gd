extends Node2D

# References to UI elements
@onready var objective_label: Label = $UI/ObjectiveLabel
@onready var dialogue_panel: ColorRect = $UI/DialoguePanel
@onready var speaker_name_label: Label = $UI/DialoguePanel/SpeakerName
@onready var dialogue_text_label: Label = $UI/DialoguePanel/DialogueText
@onready var choice_box: VBoxContainer = $UI/DialoguePanel/ChoiceBox
@onready var button_a: Button = $UI/DialoguePanel/ChoiceBox/ButtonA
@onready var button_b: Button = $UI/DialoguePanel/ChoiceBox/ButtonB

func _ready() -> void:
	# Hide the dialogue panel at start
	dialogue_panel.visible = false
	choice_box.visible = false
	update_objective_ui()

func _process(_delta: float) -> void:
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
	elif Global.current_quest == "grab_key":
		objective_label.text = "Objective: Pick up the sewer key from the bottom corner"
	elif Global.current_quest == "chapter_complete":
		objective_label.text = "CHAPTER I COMPLETE - SEWER KEY COLLECTED"
	elif Global.current_quest == "campaign_complete":
		objective_label.text = "CONGRATULATIONS! THEODORE'S DOSSIER SECURED - CHAPTER I COMPLETE"

# Public function to display the professional dialogue box
func show_dialogue(speaker: String, text: String) -> void:
	dialogue_panel.visible = true
	choice_box.visible = false # Hide choices by default
	speaker_name_label.text = speaker
	dialogue_text_label.text = text

# Public function to hide the dialogue box
func hide_dialogue() -> void:
	dialogue_panel.visible = false
	choice_box.visible = false

# Public function to display choice options for the player
func show_choices(option_a_text: String, option_b_text: String, caller_node: Node) -> void:
	choice_box.visible = true
	button_a.text = option_a_text
	button_b.text = option_b_text
	
	# Disconnect any old connections to prevent double clicks
	if button_a.pressed.is_connected(caller_node._on_button_a_pressed):
		button_a.pressed.disconnect(caller_node._on_button_a_pressed)
	if button_b.pressed.is_connected(caller_node._on_button_b_pressed):
		button_b.pressed.disconnect(caller_node._on_button_b_pressed)
		
	# Connect the buttons to the NPC script that called the dialogue
	button_a.pressed.connect(caller_node._on_button_a_pressed)
	button_b.pressed.connect(caller_node._on_button_b_pressed)