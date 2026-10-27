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

	if Global.current_quest == Global.QUEST_CHAPTER_ONE_COMPLETE and Global.theodore_knows_about_lists:
		show_dialogue(
			"Étienne de Vauclaire",
			"The ledger is full of a printer's corrections. In the margins, I found the cipher Théodore and I invented as boys. He was never hiding from these lists. He was hunting them."
		)
	elif Global.current_quest == Global.QUEST_CHAPTER_TWO_COMPLETE:
		if Global.saint_antoine_raid_choice == "protect_workers":
			show_dialogue(
				"Marguerite Colbert",
				"News travels even through locked windows. The printers escaped with most of the names. Théodore did not. Madame would call that a victory and refuse to explain whom it belonged to."
			)
		else:
			show_dialogue(
				"Étienne de Vauclaire",
				"Théodore left a trail toward the river and I chose it over the people behind me. I know where he went. I do not yet know what the knowledge cost."
			)

func _process(_delta: float) -> void:
	update_objective_ui()

func update_objective_ui() -> void:
	objective_label.text = "Objective: " + Global.get_current_objective()

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