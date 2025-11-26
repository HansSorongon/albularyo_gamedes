extends Node2D

@onready var sfx_light: AudioStreamPlayer = $SfxLight
@onready var sfx_extinguish: AudioStreamPlayer = $SfxExtinguish

var active_checkboxes: Array[String] = []

func _ready():
	
	var checkbox = get_parent().get_node("ChecklistControl")
	checkbox.checklist_changed.connect(_checklist_changed)
	
	#for i in range(5):
		#show_flame(i)

func show_flame(candle_no: int):
	get_child(candle_no).get_node("FlameBase").visible = true
	get_child(candle_no).get_node("Flame").visible = true
	
	get_child(candle_no).get_node("Flame").material.get_shader_parameter("Flame Height") = 0

func hide_flame(candle_no: int):
	get_child(candle_no).get_node("FlameBase").visible = false
	get_child(candle_no).get_node("Flame").visible = false

func _checklist_changed():
	
	active_checkboxes.clear()
	var checklist = get_parent().get_node("ChecklistControl/Checkboxes")
	
	for i in range(15):
		var current_checkbox = checklist.get_child(i)
		
		if current_checkbox.is_toggled:
			active_checkboxes.append(current_checkbox.name)
			
	for i in range(active_checkboxes.size()):
		show_flame(i)
	for i in range(active_checkboxes.size(), 5):
		hide_flame(i)
