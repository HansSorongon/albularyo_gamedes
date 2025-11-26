extends MarginContainer

@onready var label = $MarginContainer/Label
@onready var timer = $LetterDisplayTimer
@onready var sfx_dialogue: AudioStreamPlayer = $sfx_dialogue

const MAX_WIDTH = 120
var text = ""
var letter_index = 0
var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.2
signal finished_displaying()

func display_text(text_to_display: String):
	text = text_to_display
	letter_index = 0
	label.text = text_to_display  # Set full text temporarily
	
	# Reset sizes
	custom_minimum_size = Vector2.ZERO
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	await resized  # Wait for natural size calculation
	
	# Check if text is too wide
	if size.x > MAX_WIDTH:
		custom_minimum_size.x = MAX_WIDTH
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized
		custom_minimum_size.y = size.y
	
	label.text = ""
	
	# Fade in
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	await tween.finished
	
	_display_letter()

func _display_letter():
	if letter_index >= text.length():
		finished_displaying.emit()
		return
	
	label.text += text[letter_index]
	letter_index += 1
	sfx_dialogue.play()
	
	if letter_index >= text.length():
		finished_displaying.emit()
		return
		
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)

func _on_letter_display_timer_timeout() -> void:
	_display_letter()

func skip_to_end():
	timer.stop()
	letter_index = text.length()
	label.text = text
	finished_displaying.emit()

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
