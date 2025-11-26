extends Node2D

@export var rise_distance: float = 20.0
@export var duration: float = 1.0

@onready var label: Label = $Label

func _ready():
	# Ensure visible at start
	label.modulate.a = 1.0

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	# Rise up
	tween.tween_property(self, "position:y", position.y - rise_distance, duration)
	# Fade out label
	tween.parallel().tween_property(label, "modulate:a", 0.0, duration)

	# Remove once done
	tween.finished.connect(queue_free)
