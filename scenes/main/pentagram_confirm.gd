extends TextureButton

var normal_color := Color(1,1,1,1)
var hover_color := Color(1.2,1.2,1.2,1)  # slightly brighter

signal confirm_pressed()

func _ready():
	connect("pressed", Callable(self, "_button_pressed"))
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _button_pressed():
	
	var pentagram = get_parent()
	
	if not pentagram.occupied_zones["PentagramPoint6"]:
		print("No catalyst!")
	
	confirm_pressed.emit()

func _on_mouse_entered():
	modulate = hover_color

func _on_mouse_exited():
	modulate = normal_color
