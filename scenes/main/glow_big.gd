extends Sprite2D

var base_alpha := 0.3
var pulse_strength := 0.2
var pulse_speed := 1.5
var scale_strength := 0.05  # how much the size changes

func _process(delta: float) -> void:
	var time_ms = Time.get_ticks_msec()
	var t = time_ms / 1000.0

	var pulse = sin(t * pulse_speed) * pulse_strength

	# Opacity flicker
	modulate.a = clamp(base_alpha + pulse, 0.0, 1.0)

	# Scale breathing (center-based)
	scale = Vector2.ONE * (1.0 + pulse * scale_strength)
