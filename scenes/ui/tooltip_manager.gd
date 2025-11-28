extends CanvasLayer
var tooltip
var current_id = null
var fade_tween: Tween

func _ready():
	tooltip = preload("res://scenes/ui/tooltip.tscn").instantiate()
	add_child(tooltip)
	tooltip.modulate.a = 0

func show_tooltip(text: String, id):
	if fade_tween:
		fade_tween.kill()
	
	current_id = id
	tooltip.get_node("MarginContainer/Label").set_text(text)
	tooltip.reset_size()
	tooltip.visible = true
	
	fade_tween = create_tween()
	fade_tween.tween_property(tooltip, "modulate:a", 1.0, 0.1)

func hide_tooltip(id):
	if current_id == id:
		if fade_tween:
			fade_tween.kill()
		
		fade_tween = create_tween()
		fade_tween.tween_property(tooltip, "modulate:a", 0.0, 0.1)
		fade_tween.tween_callback(func(): 
			tooltip.visible = false
			tooltip.reset_size()
			current_id = null
		)
