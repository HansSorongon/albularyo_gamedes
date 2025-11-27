extends TextureButton

@export var normal_color: Color = Color(1, 1, 1, 1)
@export var hover_color: Color = Color(1.2, 1.2, 1.2, 1) # slightly brighter
@onready var sfx_click: AudioStreamPlayer = $"../SfxClick"

func _ready():
	# Connect signals
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_mouse_click)

	# Set initial color
	modulate = normal_color

func _on_mouse_click():
	sfx_click.play()

func _on_mouse_entered():
	modulate = hover_color

func _on_mouse_exited():
	modulate = normal_color
