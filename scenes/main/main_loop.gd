extends Node2D

@onready var patient_scene = preload("res://scenes/main/patient.tscn")
@onready var sfx_gold: AudioStreamPlayer = $SfxGold

var current_patient = null
var day_earnings: int = 0
var day_reputation = 0.0

func _ready():
	
	get_viewport().physics_object_picking_sort = true
	get_viewport().physics_object_picking_first_only = true
	
	spawn_patient()

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
	current_patient.get_node("PatientPathFollow").progress = 0
	
	add_child(current_patient)

func sell_potion(potencies):
	
	var patient_symptoms = current_patient.get_node("PatientPathFollow/Patient").symptoms
	#print(patient_symptoms)
	
	var total_money_earned = 0
	var total_reputation_earned = 0.0
	for symptom in patient_symptoms:
		if symptom in potencies:
			
			sfx_gold.play()
			
			var money_earned = int(min(potencies[symptom], 100))
			var reputation_earned = min(potencies[symptom], 100) / 3
			day_earnings += money_earned
			day_reputation += reputation_earned
			
			total_money_earned += money_earned
			total_reputation_earned += reputation_earned
			
		else:
			day_reputation -= 10.0
			
	MessageManager.show_message("+" + str(total_money_earned) + " P")
	current_patient.get_node("PatientPathFollow/Patient").npc_leave()
	
	get_tree().create_timer(2.0).timeout.connect(spawn_patient)

	
	#sfx_gold.play()
	#print("Sold potion ")
	#print(potencies)
