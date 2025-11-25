extends Area2D

func _ready():
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		var pentagram = get_parent()
		pentagram.remove_herb(name)
