extends Node2D

@export var is_toggled: bool = false
@export var normal_color: Color = Color(1, 1, 1, 1)    # normal color
@export var hovered_color: Color = Color(1.2, 1.2, 1.2, 1) # hover "brightened" color
@onready var sfx_tick: AudioStreamPlayer = $SfxTick

func _ready():
	$CheckMark.visible = is_toggled

	$ClickTarget.input_event.connect(_on_click)
	$ClickTarget.mouse_entered.connect(_on_hover)
	$ClickTarget.mouse_exited.connect(_on_hover_exit)

func _on_click(viewport, event, idx):
	if event.is_action_pressed("click"):
		
		var checklist = get_parent()
		var count = 0
		
		for i in range(checklist.get_child_count()):
			if checklist.get_child(i).is_toggled:
				count += 1
				
		if count < 5 or is_toggled:
			sfx_tick.play()
			toggle()

func _on_hover():
	$Box.modulate = hovered_color
	
func _on_hover_exit():
	$Box.modulate = normal_color

func toggle():
	is_toggled = !is_toggled
	$CheckMark.visible = is_toggled
