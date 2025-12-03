extends Control
var tooltip
var current_id = null
var fade_tween: Tween
var update_timer: Timer

func _ready():
	tooltip = preload("res://scenes/ui/tooltip.tscn").instantiate()
	tooltip.z_index = 500
	add_child(tooltip)
	tooltip.modulate.a = 0
	
	update_timer = Timer.new()
	update_timer.wait_time = 1.0
	update_timer.timeout.connect(_on_update_timer_timeout)
	add_child(update_timer)

func show_tooltip(text: String, id):
	if fade_tween:
		fade_tween.kill()
	
	current_id = id
	
	if id.name == "Hourglass":
		update_timer.start()
		_update_hourglass_text()
	else:
		update_timer.stop()
		tooltip.get_node("MarginContainer/Label").set_text(text)
	
	tooltip.reset_size()
	tooltip.visible = true
	
	fade_tween = create_tween()
	fade_tween.tween_property(tooltip, "modulate:a", 1.0, 0.1)

func hide_tooltip(id):
	if current_id == id:
		update_timer.stop()
		
		if fade_tween:
			fade_tween.kill()
		
		fade_tween = create_tween()
		fade_tween.tween_property(tooltip, "modulate:a", 0.0, 0.1)
		fade_tween.tween_callback(func(): 
			tooltip.visible = false
			tooltip.reset_size()
			current_id = null
		)

func _on_update_timer_timeout():
	if current_id and current_id.name == "Hourglass":
		_update_hourglass_text()

func _update_hourglass_text():
	var time_left = get_tree().current_scene.get_node("FullDayTimer").time_left
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	var text = "%d:%02d" % [minutes, seconds]
	tooltip.get_node("MarginContainer/Label").set_text(text)
	tooltip.reset_size()
