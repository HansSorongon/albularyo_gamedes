extends TextureButton
@export var normal_color: Color = Color(1, 1, 1, 1)
@export var hover_color: Color = Color(1.2, 1.2, 1.2, 1)
@export var slide_distance: float = 250.0
@export var slide_duration: float = 0.5

@onready var sfx_click: AudioStreamPlayer = $"../SfxClick"
@onready var book_instance = $"../Manual"

@onready var sfx_open: AudioStreamPlayer = $SfxOpen
@onready var sfx_close: AudioStreamPlayer = $SfxClose

var is_book_visible: bool = false

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_mouse_click)
	modulate = normal_color
	
	book_instance.z_index = 100
	book_instance.position.y = get_viewport_rect().size.y + slide_distance
	is_book_visible = false

	$"../Manual/ManualX".close.connect(_hide_book)

func _on_mouse_click():
	sfx_click.play()
	
	if is_book_visible:
		_hide_book()
	else:
		_show_book()

func _show_book():
	sfx_open.play()
	
	is_book_visible = true
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT) 
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(
		book_instance,
		"position:y",
		get_viewport_rect().size.y - slide_distance,
		slide_duration
	)

func _hide_book():
	sfx_close.play()
	
	is_book_visible = false
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(
		book_instance,
		"position:y",
		get_viewport_rect().size.y + slide_distance,
		slide_duration
	)

func _on_mouse_entered():
	modulate = hover_color

func _on_mouse_exited():
	modulate = normal_color
