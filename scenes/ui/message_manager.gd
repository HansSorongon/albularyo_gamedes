extends Node

# Preload your floating message scene
var floating_message_scene := preload("res://scenes/ui/message.tscn")

func show_message(text: String, offset: Vector2 = Vector2(0, 0)):
	var msg := floating_message_scene.instantiate()

	var label: Label = msg.get_node("Label")
	label.text = text

	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size

	# Get size from the label (message size)
	var msg_size = label.get_minimum_size()  # or .rect_size if using Control

	# Initial position slightly above the cursor
	var pos = mouse_pos + Vector2(0, -10) + offset

	# Clamp to stay fully inside viewport
	pos.x = clamp(pos.x, 0, viewport_size.x - msg_size.x / 2)
	#pos.y = clamp(pos.y, 0, viewport_size.y - msg_size.y)

	msg.position = pos
	msg.z_index = 50

	get_tree().current_scene.add_child(msg)
