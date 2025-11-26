extends Node2D
@onready var text_box_scene = preload("res://scenes/dialogue/dialogue_box.tscn")
var dialog_lines: Array[String] = []
var current_line_index = 0
var text_box
var is_dialog_active = false
var is_transitioning = false  # Add this flag

func start_dialog(lines: Array[String]):
	if is_dialog_active:
		return
		
	dialog_lines = lines
	current_line_index = 0
	is_dialog_active = true
	
	_show_text_box()

func _show_text_box():
	if not text_box:
		text_box = text_box_scene.instantiate()
		text_box.finished_displaying.connect(_on_text_box_finished_displaying)
		text_box.z_index = 999
		add_child(text_box)
		text_box.position = Vector2(2, 2)
		await get_tree().process_frame
	
	text_box.display_text(dialog_lines[current_line_index])

func _on_text_box_finished_displaying():
	if is_transitioning or not is_dialog_active:
		return
	
	is_transitioning = true
	
	await get_tree().create_timer(1.0).timeout
	text_box.fade_out()
	
	if text_box and is_instance_valid(text_box):
		await text_box.fade_out()
	
	_advance_dialog()
	
	is_transitioning = false

func _advance_dialog():
	current_line_index += 1
	
	if current_line_index >= dialog_lines.size():
		end_dialog()
		return
		
	_show_text_box()

func end_dialog():
	if text_box and is_instance_valid(text_box):
		text_box.queue_free()
		text_box = null
	
	is_dialog_active = false
	current_line_index = 0
