class_name DialogManager extends Node2D

signal finish_dialogue()
signal choice_selected(current_step: int, choice: int)

@onready var panel: Panel = $Panel
@onready var text_label: RichTextLabel = $Panel/RichTextLabel
@onready var continue_label: RichTextLabel = $Panel/ContinueLabel
@onready var choice_label: RichTextLabel = $Panel/ChoiceLabel

@export var run_test_dialogue: bool = true
@export var dialogue_width: int = 800
@export var dialogue_height: int = 400
@export var dialogue_padding: int = 20
@export var dialogue_text_size: int = 20
@export var font_size: int = 20

var current_dialogue: Array[String] = []
var current_choices: Array[Array] = []
var advance_on_choice: Array[Array] = []
var current_step: int = 0
var text_timer: Timer
var is_text_complete: bool = false
var text_speed: float = 0.03 # Time between characters
var current_text: String = ""
var current_char_index: int = 0

func _ready():
	panel.size.x = dialogue_width
	panel.size.y = dialogue_height
	text_label.position.x = dialogue_padding
	text_label.position.y = dialogue_padding
	text_label.size.x = dialogue_width - dialogue_padding * 2
	text_label.size.y = dialogue_height - dialogue_padding * 2 - font_size
	continue_label.position.x = dialogue_padding
	continue_label.size.x = dialogue_width - dialogue_padding * 2
	continue_label.position.y = dialogue_height - dialogue_padding * 2 - font_size
	choice_label.position.x = dialogue_padding
	choice_label.size.x = dialogue_width - dialogue_padding * 2
	choice_label.position.y = dialogue_height - dialogue_padding * 2 - font_size

	# Create timer for text interpolation
	text_timer = Timer.new()
	text_timer.wait_time = text_speed
	text_timer.timeout.connect(_on_text_timer_timeout)
	add_child(text_timer)
	
	# Hide everything initially
	visible = false
	text_label.text = ""
	choice_label.text = ""
	continue_label.visible = false
	
	if run_test_dialogue:
		run_dialogue(["Hello!", "This is a test!", "This is a single choice option here", "This has two options"], [[], [], ["Choice 1"], ["Choice 1", "Choice 2"]])

func run_dialogue(dialogue: Array[String], choices: Array[Array] = [], new_advance_on_choice: Array[Array] = []):
	current_dialogue = dialogue
	current_choices = choices
	advance_on_choice = new_advance_on_choice
	current_step = 0
	
	# Show the dialog panel
	visible = true
	
	# Start with the first step
	if current_dialogue.size() > 0:
		_display_dialogue_step(current_dialogue[0])
		
func go_to_step(new_step):
	current_step = new_step
	_display_dialogue_step(current_dialogue[new_step])

func _display_dialogue_step(text: String):
	# Reset text interpolation
	current_text = text
	current_char_index = 0
	is_text_complete = false
	text_label.text = ""
	
	# Hide continue and choice labels
	continue_label.visible = false
	choice_label.visible = false
	
	# Start text interpolation
	text_timer.start()

func _on_text_timer_timeout():
	if current_char_index < current_text.length():
		text_label.text += current_text[current_char_index]
		current_char_index += 1
	else:
		# Text is complete
		text_timer.stop()
		is_text_complete = true
		_handle_dialogue_finish()

func _display_choices(choices: Array):
	choice_label.visible = true
	
	# Build choice text
	var choice_text = "Y: %s" % choices[0]
	if choices.size() > 1:
		choice_text += "    N: %s" % choices[1]

	choice_label.text = choice_text

func _display_continue_label():
	continue_label.visible = true

func _handle_dialogue_finish():
	# Check if we have choices for this step
	var step_choices: Array = []
	if current_choices.size() > current_step and current_choices[current_step].size() > 0:
		step_choices = current_choices[current_step]
	
	if step_choices.size() > 0:
		_display_choices(step_choices)
	else:
		_display_continue_label()

func _input(event):
	if not visible:
		return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			_handle_space_press()
		if event.keycode == KEY_Y:
			_handle_choice_input(0)
		if event.keycode == KEY_N:
			_handle_choice_input(1)

func _handle_space_press():
	if not is_text_complete:
		# Skip text interpolation
		text_timer.stop()
		text_label.text = current_text
		is_text_complete = true
		_handle_dialogue_finish()
		return
	
	if continue_label.visible:
		_advance_dialogue()

func _handle_choice_input(choice_index: int):
	var temp_current_step = current_step # current_step might change during the emit
	if current_step >= current_choices.size():
		return
	var step_choices: Array = current_choices[current_step]
	if choice_index < step_choices.size():
		choice_selected.emit(current_step, choice_index)
		if temp_current_step < advance_on_choice.size() and choice_index < advance_on_choice[temp_current_step].size() and !advance_on_choice[temp_current_step][choice_index]:
			return
		_advance_dialogue()

func _advance_dialogue():
	current_step += 1
	
	if current_step < current_dialogue.size():
		# Move to next step
		_display_dialogue_step(current_dialogue[current_step])
	else:
		# Dialogue is complete
		finish_dialogue.emit()
		visible = false
