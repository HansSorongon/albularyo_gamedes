extends AnimatedSprite2D

func _ready():
	$Area2D.mouse_entered.connect(_on_mouse_entered)
	$Area2D.mouse_exited.connect(_on_mouse_exited)
	
func _on_mouse_entered():
	TooltipManager.show_tooltip("Time: ", self)

func _on_mouse_exited():
	TooltipManager.hide_tooltip(self)
