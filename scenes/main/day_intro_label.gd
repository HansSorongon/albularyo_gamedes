extends Label

@export var text_to_show: String
@export var type_speed: float = 0.2   # seconds per character (tweak for faster/slower)
@onready var sfx_gold: AudioStreamPlayer = $"../SfxGold"

@onready var sfx_typewriter = [$"../SfxTypewriter1", $"../SfxTypewriter2", $"../SfxTypewriter3", $"../SfxTypewriter4", $"../SfxTypewriter5", $"../SfxTypewriter6"]

var can_continue: bool = false

func _ready():
	
	text_to_show = "Day " + str(GameState.day_number)
	
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
	
	await get_tree().create_timer(0.6).timeout

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

func start_new_day():		
	TransitionScript.fade_to_scene_path("res://scenes/main/main_loop.tscn")
			
