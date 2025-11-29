extends Node

@onready var cursor = preload("res://assets/ui/cursor.png")
@onready var cursor_x = preload("res://assets/ui/cursor_x.png")

func change_cursor_to_default():
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(16, 16))
	
func change_cursor_to_x():
	Input.set_custom_mouse_cursor(cursor_x, Input.CURSOR_ARROW, Vector2(16, 16))
