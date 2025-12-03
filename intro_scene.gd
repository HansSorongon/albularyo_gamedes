extends Node

@onready var logo = $Gole
@onready var label = $Label
@onready var sfx_gole: AudioStreamPlayer = $SfxGole

func _ready():
	# Start with everything invisible/transparent
	logo.modulate.a = 0
	label.modulate.a = 0
	
	# Start animation sequence
	play_opening_sequence()

func play_opening_sequence():
	# Fade in logo
	var logo_tween = create_tween()
	logo_tween.tween_property(logo, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_IN)
	
	# Wait a moment, then fade in label
	await get_tree().create_timer(1.2).timeout
	var label_tween = create_tween()
	label_tween.tween_property(label, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_IN)
	
	# Hold for a moment
	sfx_gole.play()
	await get_tree().create_timer(2.0).timeout
	
	# Fade everything out
	var fadeout_tween = create_tween()
	fadeout_tween.set_parallel(true)
	fadeout_tween.tween_property(logo, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_OUT)
	fadeout_tween.tween_property(label, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_OUT)
	
	
	
	TransitionScript.fade_to_scene_path("res://scenes/main/main_menu.tscn")
