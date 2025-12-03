extends ColorRect

func move_box(box_location: Vector2, clear_area: Vector2 = Vector2(0.4, 0.5)):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self.material, "shader_parameter/center_offset", box_location, 2.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self.material, "shader_parameter/clear_area_size", clear_area, 2.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	await tween.finished

func _ready():
	pass
	
	
		#tween_pentagram = create_tween()
	#tween_pentagram.tween_property($PentagramSprite.material, "shader_parameter/fade", 0.0, 0.6)
	#tween_pentagram.set_ease(Tween.EASE_OUT)
	#tween_pentagram.tween_callback(func():
		#$PentagramSprite.material.set_shader_parameter("progress", 0.0)
		#$PentagramSprite.material.set_shader_parameter("fade", 1.0)
	#)
