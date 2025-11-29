extends MarginContainer

var tween: Tween

func _ready():
	$MarginContainer/Label.text = "EXIT"
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	modulate = Color.WHITE

func _on_mouse_entered():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", Color(1.3, 1.3, 1.3), 0.15)

func _on_mouse_exited():
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", Color.WHITE, 0.15)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		get_tree().quit()
