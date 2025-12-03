extends Node2D

@onready var text_box_scene = preload("res://scenes/dialogue/dialogue_box.tscn")

var dialog_lines: Array[String] = []
var current_line_index = 0
var text_box = null
var is_dialog_active = false
var is_transitioning = false
var is_tutorial_box = false
var tb_position = Vector2(2, 2)
var z_ind = 650

signal dialogue_finished

func start_dialog(lines: Array[String], tb_position: Vector2 = Vector2(2,2), z_ind = 650, is_tutorial = false):
	if is_dialog_active:
		return
	
	dialog_lines = lines
	current_line_index = 0
	is_dialog_active = true
	is_tutorial_box = is_tutorial
	self.tb_position = tb_position
	self.z_ind = z_ind
	_show_text_box()

func _show_text_box():
	if not text_box:
		text_box = text_box_scene.instantiate()
		text_box.is_tutorial_box = is_tutorial_box
		if not is_tutorial_box:
			text_box.finished_displaying.connect(_on_text_box_finished_displaying)
		text_box.z_index = z_ind
		add_child(text_box)
		text_box.position = tb_position
		await get_tree().process_frame
	
	text_box.display_text(dialog_lines[current_line_index])

func _input(event):
	# Check if tutorial mode and user clicked
	if is_tutorial_box and is_dialog_active and not is_transitioning:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_advance_tutorial_dialog()

func _advance_tutorial_dialog():
	if is_transitioning:
		return
	
	is_transitioning = true
	
	if text_box and is_instance_valid(text_box):
		await text_box.fade_out()
	
	_advance_dialog()
	is_transitioning = false

func _on_text_box_finished_displaying():
	if is_transitioning or not is_dialog_active:
		return
	
	is_transitioning = true
	await get_tree().create_timer(1.0).timeout
	
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
	dialogue_finished.emit()
