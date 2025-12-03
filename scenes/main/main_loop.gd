extends Node2D

@onready var pause_menu: Control = $PauseMenu
@onready var sfx_pause: AudioStreamPlayer = $SfxPause

@onready var patient_scene = preload("res://scenes/main/patient.tscn")
@onready var sfx_gold: AudioStreamPlayer = $SfxGold
@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var background_cricket: AudioStreamPlayer = $BackgroundCricket

var paused = false
var waiting_for_click = false
signal click_detected()

var current_patient = null
var day_earnings: int = 0
var day_reputation = 0.0

var day_seconds = 300

var total_hourglass_frames = 7
var last_frame = -1

var night_progress = 0.0

var is_spawning = true

var tutorial = true

func _ready():
	
	$WorkstationUI/DialogueRepeatButton.pressed.connect(_on_dialogue_repeat)
	
	get_viewport().physics_object_picking_sort = true
	get_viewport().physics_object_picking_first_only = true
	
	print(GameState.day_number)
	if GameState.day_number == 1 and tutorial:
		start_tutorial()
	else:
		spawn_patient()
	
	$FullDayTimer.wait_time = day_seconds
	
	background_music.play()
	
	$Rain.visible = true
	$NightOverlay.visible = false
	$FullDayTimer.start()
	$NightTimer.start()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_Q:
			get_tree().quit()
		#if event.keycode == KEY_R:
			#spawn_patient()
	if waiting_for_click and event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			click_detected.emit()
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_D:
			if current_patient:
				print(current_patient.get_node("PatientPathFollow/Patient").patient_dialogue)
				print(current_patient.get_node("PatientPath/PatientPathFollow/Patient").patient_dialogue)

func start_tutorial():
	
	$ChecklistControl/Area2D.input_pickable = false
	$WorkstationUI/BookToggle/Area2D.input_pickable = false
	$WorkstationUI/Manual/ManualX.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$WorkstationUI/Manual/ManualPageFlipButtons/ManualNext.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$WorkstationUI/Manual/ManualPageFlipButtons/ManualBack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for i in range(15):
		$ChecklistControl/Checkboxes.get_child(i).get_node("ClickTarget").input_pickable = false
	
	if current_patient:
		remove_child(current_patient)
		
	current_patient = patient_scene.instantiate()
	current_patient.get_node("PatientPathFollow").progress = 0
	current_patient.get_node("PatientPathFollow/Patient").is_tutorial = true
	
	add_child(current_patient)

	await $Vignette.move_box(Vector2(-0.5, -0.3), Vector2(0.6, 0.7))

	DialogueManager.start_dialog(["A new patient has arrived.", "Your goal is to craft a potion that cures the symptoms they are suffering from."], Vector2(1, 70), 950, true)
	
	await DialogueManager.dialogue_finished
	waiting_for_click = true
	await click_detected
	waiting_for_click = false
		
	DialogueManager.start_dialog(["Let’s start with a visual diagnosis.", "This patient clearly has rashes."], Vector2(1, 70), 950, true)
	await $Vignette.move_box(Vector2(-0.365, -0.12), Vector2(0.13, 0.285))

	await DialogueManager.dialogue_finished
	DialogueManager.start_dialog(["But appearance isn’t everything.", "Let’s listen to what they have to say."], Vector2(1, 70), 950, true)
	await DialogueManager.dialogue_finished
	
	await $Vignette.move_box(Vector2(-0.365, -0.25), Vector2(0.7, 0.7))
	
	if not DialogueManager.is_dialog_active:
		DialogueManager.start_dialog(current_patient.get_node("PatientPathFollow/Patient").patient_dialogue)

	await DialogueManager.dialogue_finished
	waiting_for_click = true
	await click_detected
	waiting_for_click = false

	DialogueManager.start_dialog(["You heard them.", "Let's add rashes and cough to your symptoms list."], Vector2(1, 70), 950, true)

	await DialogueManager.dialogue_finished
	await $Vignette.move_box(Vector2(0, 0), Vector2(1, 1))
	DialogueManager.start_dialog(["Bring out your list by hovering on the bottom right."], Vector2(50, 110), 950, true)
	await DialogueManager.dialogue_finished
	
	$ChecklistControl/Area2D.input_pickable = true
	await $ChecklistControl.checklist_opened
	
	await get_tree().create_timer(0.6).timeout
	DialogueManager.start_dialog(["Now check off rashes and cough."], Vector2(50, 110), 950, true)
	await DialogueManager.dialogue_finished
	
	for i in range(15):	
		$ChecklistControl/Checkboxes.get_child(i).get_node("ClickTarget").input_pickable = true
	
	await $ChecklistControl.checklist_changed
	
	while true:
		await $ChecklistControl.checklist_changed


		var checked: Array[String] = []
		for i in range(15):
			var sym = $ChecklistControl/Checkboxes.get_child(i)
			if sym.is_toggled:
				checked.append(sym.name)

		if "rashes" in checked and "cough" in checked:
			break

	await get_tree().create_timer(0.6).timeout
		
	DialogueManager.start_dialog([
	"Perfect. The candles lit up.", 
	"Each candle represents a symptom.", 
	"When one shines brightest, it means your potion will fully cure that symptom.",
	"You can hover over the candle to see which symptom it targets.",
	"Now open your manual to see which ingredients can help."
	],
	Vector2(10, 50), 950, true)
	
	await DialogueManager.dialogue_finished
			
	await $Vignette.move_box(Vector2(-0.008, 0.45), Vector2(0.13, 0.285))
	$WorkstationUI/BookToggle/Area2D.input_pickable = true
	
	await $WorkstationUI/BookToggle.book_opened
	
	await $Vignette.move_box(Vector2(0, 0), Vector2(1, 1))
	await get_tree().create_timer(0.6).timeout
	await $Vignette.move_box(Vector2(0.15, -0.1), Vector2(0.4, 0.6))
	
	DialogueManager.start_dialog([
	"This ingredient cures cough, headache, red eyes, and runny nose when placed in the center of the ritual circle.",
	"The center of the ritual circle is where you place your catalyst.",
	"Let's try it out. Place this herb in the middle of the ritual circle."
	],
	Vector2(110, 70), 950, true)
	
	await DialogueManager.dialogue_finished
	await $Vignette.move_box(Vector2(0, 0), Vector2(1, 1))
	
	$WorkstationUI/Manual/ManualX.mouse_filter = Control.MOUSE_FILTER_STOP
	
	await $Workstation/Pentagram.changed_potency
	while $Workstation/Pentagram.occupied_names["PentagramPoint6"] != "Lagundi":
		await $Workstation/Pentagram.changed_potency
		
	DialogueManager.start_dialog([
	"See that?",
	"The candle for cough lit up. That's because our catalyst cures cough."
	],
	Vector2(5, 40), 950, true)
	await DialogueManager.dialogue_finished
	
	await get_tree().create_timer(0.3).timeout
	
	DialogueManager.start_dialog([
	"Now we have to find a cure for rashes.",
	"This time, we only have the supporting circles to work with.",
	"Let's check the manual again."
	],
	Vector2(5, 40), 950, true)
	await DialogueManager.dialogue_finished
	
	$WorkstationUI/BookToggle/Area2D.input_pickable = true # TEMP-------------
	
	await $WorkstationUI/BookToggle.book_opened
	
	await get_tree().create_timer(0.6).timeout
	await $Vignette.move_box(Vector2(0.15, 0.2), Vector2(0.4, 0.6))
	
	DialogueManager.start_dialog([
	"This ingredient only cures sore throat when put in a supporting circle.",
	"Let's find one that can help."
	],
	Vector2(110, 20), 950, true)
	
	await DialogueManager.dialogue_finished
	await $Vignette.move_box(Vector2(0, 0), Vector2(1, 1))

	$WorkstationUI/Manual/ManualPageFlipButtons/ManualNext.mouse_filter = Control.MOUSE_FILTER_STOP
	$WorkstationUI/Manual/ManualPageFlipButtons/ManualBack.mouse_filter = Control.MOUSE_FILTER_STOP

	await $WorkstationUI/Manual/ManualPageFlipButtons/ManualNext.page_next
	
	while $WorkstationUI/Manual.current_page != 5:
		await $WorkstationUI/Manual/ManualPageFlipButtons/ManualNext.page_next
		
	await get_tree().create_timer(0.6).timeout
	DialogueManager.start_dialog([
	"This will do.",
	"Let's put it on the outer circle."
	],
	Vector2(120, 47), 950, true)
	
	$WorkstationUI/Manual/ManualX.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var found_ginhawa = false
	while true:
		await $Workstation/Pentagram.changed_potency
		
		for i in range(5):
			if $Workstation/Pentagram.occupied_names["PentagramPoint" + str(i + 1)] == "Ginhawa":
				found_ginhawa = true
				break;
		
		if found_ginhawa:
			break;
			
	DialogueManager.start_dialog([
	"The flame got stronger.",
	"Some herbs have stronger interactions with others but this works for now.",
	"Let's add more of it."
	],
	Vector2(5, 40), 950, true)
	
	found_ginhawa = false
	var total_ginhawa = 0
	while true:
		await $Workstation/Pentagram.changed_potency
		for i in range(5):
			
			if $Workstation/Pentagram.occupied_names["PentagramPoint" + str(i + 1)] == "Ginhawa":
				
				total_ginhawa += 1
		
		if total_ginhawa >= 3:
			break;
			
	DialogueManager.start_dialog([
	"There. Now they're all fully lit",
	"Let's perform the ritual.",
	],
	Vector2(5, 40), 950, true)
	
	await DialogueManager.dialogue_finished
	await get_tree().create_timer(0.6).timeout
	
	await $Vignette.move_box(Vector2(0.25, 0.2), Vector2(0.7, 0.6))
	
	DialogueManager.start_dialog([
	"Click the triangle to start the ritual.",
	],
	Vector2(115, 40), 950, true)
	
	await $Workstation/Pentagram/PentagramConfirm.confirm_pressed
	await get_tree().create_timer(1.5).timeout
	
	DialogueManager.start_dialog([
	"Well done.",
	"Hand that potion to the patient and I'll leave the rest to you.",
	],
	Vector2(115, 40), 950, true)
	
	await $Vignette.move_box(Vector2(0, 0), Vector2(1, 1))

func spawn_patient():
	if current_patient:
		remove_child(current_patient)
	
	current_patient = patient_scene.instantiate()
	current_patient.get_node("PatientPathFollow").progress = 0
	
	add_child(current_patient)

	if not DialogueManager.is_dialog_active:
		DialogueManager.start_dialog(current_patient.get_node("PatientPathFollow/Patient").patient_dialogue)

func sell_potion(potencies):
	
	var patient_symptoms = current_patient.get_node("PatientPathFollow/Patient").symptoms
	#print(patient_symptoms)
	
	var total_money_earned = 0
	var total_reputation_earned = 0.0
	for symptom in patient_symptoms:
		if symptom in potencies:
			
			sfx_gold.play()
			
			var money_earned = int(min(potencies[symptom], 100))
			
			var reputation_earned = 0.0
			if potencies[symptom] >= 50.0:
				reputation_earned = 10
				reputation_earned += (potencies[symptom] - 50.0) / 5
				
			day_earnings += money_earned
			day_reputation += reputation_earned
			
			total_money_earned += money_earned
			total_reputation_earned += reputation_earned
			
		else:
			total_reputation_earned -= 30.0
			day_reputation -= 30.0
			
	#MessageManager.show_message("+" + str(total_money_earned) + " P")
	var msg = ""
	if total_reputation_earned >= 0.0:
		msg += "+"
		GameState.day_patients_cured += 1
	
	GameState.day_total_patients += 1
	GameState.total_reputation += int(total_reputation_earned)
	msg += str(int(total_reputation_earned)) + " Rep"
	
	MessageManager.show_message(msg)
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
	GameState.day_number += 1

	TransitionScript.fade_to_scene_path("res://scenes/results/results.tscn")

func _on_night_timer_timeout() -> void:
	if night_progress < 1.0:
		night_progress += 1.0 / day_seconds
		$NpcBackground.material.set_shader_parameter("progress", night_progress)

func _on_dialogue_repeat():
	if current_patient:
		if not DialogueManager.is_dialog_active:
			var patient_dialogue = current_patient.get_node("PatientPathFollow/Patient").patient_dialogue
			DialogueManager.start_dialog(patient_dialogue)

func _on_full_day_timer_timeout() -> void:
	
	background_cricket.volume_db = -80
	$Rain.visible = false
	$NightOverlay.visible = true
	$NightOverlay.material.set_shader_parameter("fade", 0.0)

	var tween = create_tween()
	tween.tween_method(
		func(value): $NightOverlay.material.set_shader_parameter("fade", value),
		0.0,
		1.0,
		0.5
	)
	
	$Hourglass/Sand.visible = false
	background_cricket.play()
	
	var tween_out = create_tween()
	var tween_in = create_tween()
	
	tween_out.tween_property(background_music, "volume_db", -80, 8)
	tween_out.tween_callback(background_music.stop)
	
	tween_in.tween_property(background_cricket, "volume_db", -10, 3)
	
	is_spawning = false
		
func _process(_delta):
	
	if $FullDayTimer.time_left > 0:
		var elapsed = day_seconds - $FullDayTimer.time_left
		var current_frame_float = elapsed / (day_seconds / total_hourglass_frames)
		var current_frame = int(floor(current_frame_float))
		
		if current_frame != last_frame and current_frame < total_hourglass_frames:
			last_frame = current_frame
			$Hourglass.frame = current_frame
