extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
var tween: Tween

func _ready() -> void:
	if not color_rect:
		color_rect = ColorRect.new()
		color_rect.name = "ColorRect"
		color_rect.color = Color.BLACK
		color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(color_rect)
	
	color_rect.modulate.a = 0.0
	get_viewport().size_changed.connect(_resize)
	_resize()

func _resize() -> void:
	if color_rect:
		color_rect.size = get_viewport().get_visible_rect().size

func fade_to_scene_path(scene_path: String, duration: float = 0.6) -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	tween.tween_callback(func(): get_tree().change_scene_to_file(scene_path))
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)

func fade_to_packed(packed_scene: PackedScene, duration: float = 0.6) -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	tween.tween_callback(func(): get_tree().change_scene_to_packed(packed_scene))
	tween.tween_property(color_rect, "modulate:a", 0.0, duration)

func fade_in(duration: float = 0.6) -> void:
	color_rect.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_property(color_rect, "modulate:a", 0.0, duration)
