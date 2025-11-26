extends Node2D

@onready var patient_scene = preload("res://scenes/main/patient.tscn")

var current_patient = null

func _ready():
	spawn_patient()
	
	get_viewport().physics_object_picking_sort = true
	get_viewport().physics_object_picking_first_only = true

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q:
			get_tree().quit()
		if event.keycode == KEY_R:
			spawn_patient()

			
func spawn_patient():
	if current_patient:
		remove_child(current_patient)
	
	current_patient = patient_scene.instantiate()
	add_child(current_patient)
