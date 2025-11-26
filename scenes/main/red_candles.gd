extends Node2D

@onready var sfx_light: AudioStreamPlayer = $SfxLight
@onready var sfx_extinguish: AudioStreamPlayer = $SfxExtinguish
@onready var sfx_feedback: AudioStreamPlayer = $SfxFeedback

var active_checkboxes: Array[String] = []

func _ready():
	
	var checkbox = get_parent().get_node("ChecklistControl")
	checkbox.checklist_changed.connect(_checklist_changed)
	var pentagram = get_parent().get_node("Workstation/Pentagram")
	pentagram.changed_potency.connect(_on_change_potency)
	
	#for i in range(5):
		#show_flame(i)

var min_flame_vals = [0.315, 1.25, 0.2]
var max_flame_vals = [2.78, 2.26, 0.8]

func _on_change_potency():
	
	var pentagram = get_parent().get_node("Workstation/Pentagram")

	for i in range(active_checkboxes.size()):
		reset_flame(i)

	for symptom in pentagram.potencies:
		var index = active_checkboxes.find(symptom)
		if index != -1:
			#print(pentagram.potencies[symptom])
			var ratio = pentagram.potencies[symptom] / 100
			var sine_ratio = sin(ratio * PI / 2)
			
			var new_flame_height = min_flame_vals[0] + (max_flame_vals[0] - min_flame_vals[0]) * ratio
			var new_flame_width = min_flame_vals[1] + (max_flame_vals[1] - min_flame_vals[1]) * sine_ratio
			var new_flame_speed = min_flame_vals[2] + (max_flame_vals[2] - min_flame_vals[2]) * sine_ratio
			
			if ratio >= 1:
				sfx_feedback.play()
			
			get_child(index).get_node("Flame").material.set_shader_parameter("flame_height", new_flame_height)
			get_child(index).get_node("Flame").material.set_shader_parameter("flame_width", new_flame_width)
			get_child(index).get_node("Flame").material.set_shader_parameter("flame_speed", new_flame_speed)

func reset_flame(candle_no: int):
	get_child(candle_no).get_node("Flame").material.set_shader_parameter("flame_height", 0.315)
	get_child(candle_no).get_node("Flame").material.set_shader_parameter("flame_width", 1.25)
	get_child(candle_no).get_node("Flame").material.set_shader_parameter("scroll_speed", 0.2)

func show_flame(candle_no: int):
	get_child(candle_no).get_node("FlameBase").visible = true
	get_child(candle_no).get_node("Flame").visible = true
	
	#get_child(candle_no).get_node("Flame").material.get_shader_parameter("Flame Height") = 0
	
	#var tween = create_tween()
	reset_flame(candle_no)


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
		_on_change_potency()
	for i in range(active_checkboxes.size(), 5):
		hide_flame(i)
