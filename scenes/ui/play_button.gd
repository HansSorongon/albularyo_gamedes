extends MarginContainer

@onready var sfx_play: AudioStreamPlayer2D = $"../SfxPlay"

var tween: Tween
var is_transitioning: bool = false

func _ready():
	$MarginContainer/Label.text = "PLAY"
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
	if is_transitioning:
		return
		
	if event.is_action_pressed("click"):
		is_transitioning = true
		
		var parent = get_parent()
		for child in parent.get_children():
			if child is MarginContainer or child is Button:
				child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		MusicManager.stop_music()
		sfx_play.play()
		TransitionScript.fade_to_scene_path("res://scenes/main/main_loop.tscn", 5.58)
