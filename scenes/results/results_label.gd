extends Label

@export var text_to_show: String = "The day comes to a close..."
@export var type_speed: float = 0.05   # seconds per character (tweak for faster/slower)
@onready var sfx_gold: AudioStreamPlayer = $"../SfxGold"

@onready var sfx_typewriter = [$"../SfxTypewriter1", $"../SfxTypewriter2", $"../SfxTypewriter3", $"../SfxTypewriter4", $"../SfxTypewriter5", $"../SfxTypewriter6"]

var can_continue: bool = false

func _ready():
	text = ""
	visible_characters = 0
	start_typewriter()

func start_typewriter():
	text = text_to_show
	visible_characters = 0
	
	for i in text.length():
		await get_tree().create_timer(type_speed).timeout
		visible_characters = i + 1
		sfx_typewriter[randi() % 6].play()
	
	# small pause after text is fully shown
	await get_tree().create_timer(1.0).timeout
	on_typewriter_finished()
	
func on_typewriter_finished():
	$'../Label2'.text = "Patients Cured: " + str(GameState.day_patients_cured) + "/" + str(GameState.day_total_patients)
	sfx_gold.play()
	
	await get_tree().create_timer(0.6).timeout
	
	$'../Label3'.text = "Reputation: " + get_reputation_word(int(GameState.total_reputation))
	sfx_gold.play()
	
	await get_tree().create_timer(0.6).timeout
	
	#$'../Label5'.text = "Total Reputation: " + str(int(GameState.total_reputation))
	#sfx_gold.play()
	##
	#await get_tree().create_timer(0.6).timeout
	
	GameState.day_earnings = 0
	GameState.day_reputation = 0
	GameState.day_patients_cured = 0
	GameState.day_total_patients = 0
	
	$'../Label4'.text = "Click anywhere to continue..."
	can_continue = true

func _input(event):
	if not can_continue:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if can_continue:
			can_continue = false
			start_new_day()
	
	elif event is InputEventScreenTouch and event.pressed:
		if can_continue:
			can_continue = false
			start_new_day()

func get_reputation_word(reputation: int) -> String:
	if reputation < -140:
		return "Hated"
	elif reputation < -70:
		return "Disliked"
	elif reputation < 70:
		return "Neutral"
	elif reputation < 140:
		return "Liked"
	elif reputation < 210:
		return "Respected"
	else:
		return "Legendary"
	
func start_new_day():
	print("Starting new day...")		
	TransitionScript.fade_to_scene_path("res://scenes/main/day_introduction.tscn")
			
