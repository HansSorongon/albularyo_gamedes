extends MarginContainer

@onready var label = $MarginContainer/Label

func _ready():
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func set_test(text: String):
	label.text = text
	
func _process(_delta):
	if visible:
		global_position = get_global_mouse_position() + Vector2(-15, -15)
