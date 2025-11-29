extends Area2D

@onready var sfx_remove: AudioStreamPlayer = $SfxRemove
@onready var cursor = preload("res://assets/ui/cursor_x.png")

func _ready():
	connect("input_event", Callable(self, "_on_input_event"))
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
func _on_mouse_entered():
	Cursor.change_cursor_to_x()

func _on_mouse_exited():
	Cursor.change_cursor_to_default()

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		sfx_remove.play()
		var pentagram = get_parent()
		pentagram.remove_herb(name)
