extends Sprite2D

@export var herb_name: String = "Lagundi"

var hover_color := Color(1.2, 1.2, 1.2, 1)
var normal_color := Color(1, 1, 1, 1)

func _ready():
	$ClickTarget.input_event.connect(_on_click_target_input)
	$ClickTarget.mouse_entered.connect(_on_mouse_entered)
	$ClickTarget.mouse_exited.connect(_on_mouse_exited)
	
func _on_click_target_input(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		print(herb_name)

func _on_mouse_entered():
	modulate = hover_color
	
func _on_mouse_exited():
	modulate = normal_color
