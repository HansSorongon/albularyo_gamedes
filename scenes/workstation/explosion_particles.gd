extends GPUParticles2D

func _ready() -> void:
	one_shot = true
	#restart()
	
	# This single block fixes the "blink out" forever:
	if process_material:
		process_material.color = Color(1, 1, 1, 1)
		var ramp = GradientTexture1D.new()
		var gradient = Gradient.new()
		gradient.colors = [Color(1,1,1,1), Color(1,1,1,0)]
		gradient.offsets = [0.0, 1.0]
		ramp.gradient = gradient
		process_material.color_ramp = ramp
