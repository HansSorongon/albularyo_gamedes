extends MarginContainer

@export var button_text = ""


func _ready():
	$MarginContainer/Label.text = button_text
