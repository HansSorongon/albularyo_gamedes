extends Node2D

@onready var patient_scene = preload("res://scenes/main/patient.tscn")
@onready var sfx_gold: AudioStreamPlayer = $SfxGold

var current_patient = null
var day_earnings: int = 0
var day_reputation = 0.0

var day_seconds = 180
var night_progress = 0.0

var is_spawning = true

func _ready():
	
	get_viewport().physics_object_picking_sort = true
	get_viewport().physics_object_picking_first_only = true
	
	spawn_patient()
	
	$FullDayTimer.wait_time = day_seconds
	
	$FullDayTimer.start()
	$NightTimer.start()

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
	$ChecklistControl.clear_checkboxes()
	$RedCandles.hide_flames()
	
	if is_spawning:
		get_tree().create_timer(2.0).timeout.connect(spawn_patient)
	else:
		get_tree().create_timer(2).timeout.connect(end_day)
		
		
func end_day():
	
	GameState.day_earnings = day_earnings
	GameState.total_money += day_earnings
	GameState.day_reputation = day_reputation

	TransitionScript.fade_to_scene_path("res://scenes/results/results.tscn")

func _on_night_timer_timeout() -> void:
	if night_progress < 1.0:
		night_progress += 1.0 / day_seconds
		$NpcBackground.material.set_shader_parameter("progress", night_progress)

func _on_full_day_timer_timeout() -> void:
	print("ready for next day")
	is_spawning = false
