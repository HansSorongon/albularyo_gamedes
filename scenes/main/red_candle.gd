extends Sprite2D

var symptom_name = "None"

func _ready():
	
	$Area2D.mouse_entered.connect(_on_mouse_entered)
	$Area2D.mouse_exited.connect(_on_mouse_exit)
	
func to_title(text: String) -> String:
	var words = text.replace("_", " ").split(" ")
	for i in range(words.size()):
		words[i] = words[i].capitalize()
	return " ".join(words)
	
func _on_mouse_entered():
	TooltipManager.show_tooltip(to_title(symptom_name.replace("_", " ")), self)
	
func _on_mouse_exit():
	TooltipManager.hide_tooltip(self)
