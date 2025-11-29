extends TextureButton

@export var normal_color: Color = Color(1, 1, 1, 1)
@export var hover_color: Color = Color(1.2, 1.2, 1.2, 1)

signal close()

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_mouse_click)
	modulate = normal_color

func _on_mouse_click():
	close.emit()

func _on_mouse_entered():
	modulate = hover_color

func _on_mouse_exited():
	modulate = normal_color
