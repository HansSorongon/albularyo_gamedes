extends PathFollow2D

var speed = 400
var time = 0.0
var duration = 2.0

func _process(delta):
	time += delta
	var t = clamp(time / duration, 0.0, 1.0)
	var eased_t = sin(t * PI / 2.0)
	
	progress_ratio = eased_t
