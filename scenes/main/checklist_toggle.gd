extends Sprite2D

@export var slide_offset: Vector2 = Vector2(-100, -120)  # how far to slide
@export var slide_speed: float = 1200.0                 # pixels per second
@onready var sfx_open: AudioStreamPlayer = $SfxOpen
@onready var sfx_close: AudioStreamPlayer = $SfxClose

var closed_position: Vector2
var target_position: Vector2
var is_open: bool = false

var possible_symptoms: Array[String] = [
	"Pale Skin",
	"Pale Lips",
	"Sweat",
	"Fever",
	"Sunken Eyes",
	"Red Eyes",
	"Runny Nose",
	"Red Nose",
	"Hollow Cheeks",
	"Rashes",
	"Wound",
	"Chest Pain",
	"Cough",
	"Sore Throat",
	"Headache"
]

func _ready():
	
	for i in range(15):
		var node = $Checkboxes.get_child(i)
		node.get_node("Label").text = possible_symptoms[i]
	
	closed_position = position
	target_position = position

	$Area2D.mouse_entered.connect(_on_mouse_entered)

func _on_mouse_entered():
	if not is_open:
		sfx_open.play()
		is_open = true
		target_position = closed_position + slide_offset  # move diagonally
		print("open")

func _process(delta):
	# Check mouse x position for automatic closing
	var mouse_pos = get_viewport().get_mouse_position()
	if is_open and mouse_pos.x < 100:
		is_open = false
		sfx_close.play()
		target_position = closed_position
		print("close")

	# Smooth movement towards target
	position = position.lerp(target_position, delta * slide_speed / slide_offset.length())
