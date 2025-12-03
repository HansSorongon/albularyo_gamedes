extends Node

var paused = false
var transitioning = false
@onready var pause_menu: Control
var sfx_pause: AudioStreamPlayer


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu = preload("res://scenes/ui/PauseMenu.tscn").instantiate()
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(pause_menu)
	pause_menu.hide()

	sfx_pause = AudioStreamPlayer.new()
	sfx_pause.stream = preload("res://assets/audio/pause.wav")
	sfx_pause.volume_db = -5
	sfx_pause.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(sfx_pause)

func _input(_event):
	
	if not get_tree().current_scene:
		return
		
	if not get_tree().current_scene.is_in_group("pausable_scenes"):
		return
	
	if Input.is_action_just_pressed("pause") and not transitioning:
		#print("TEST")
		sfx_pause.play()
		toggle_pause_menu()

func toggle_pause_menu():
	transitioning = true
	
	if paused:
		
		var tween = create_tween()
		tween.tween_property(pause_menu, "modulate:a", 0.0, 0.2)
		tween.parallel().tween_property(pause_menu, "scale", Vector2(0.8, 0.8), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await tween.finished
		pause_menu.hide()
		get_tree().paused = false
		#Engine.time_scale = 1
	else:

		pause_menu.modulate.a = 0.0
		pause_menu.scale = Vector2(0.8, 0.8)
		pause_menu.show()

		var tween = create_tween()
		tween.tween_property(pause_menu, "modulate:a", 1.0, 0.2)
		tween.parallel().tween_property(pause_menu, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await tween.finished

		get_tree().paused = true
		
	paused = !paused
	transitioning = false
