extends Node2D

@onready var area := $Area2D

var is_dragging := false
var drag_offset := Vector2.ZERO

var potencies = {}

func random_color_vec4() -> Vector4:
	return Vector4(randf(), randf(), randf(), 1.0)

func _ready() -> void:
	add_to_group("potion")
	
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)
	
	$BottleInside.material.set_shader_parameter("night_tint", random_color_vec4())

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset

func _on_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		is_dragging = true
		drag_offset = global_position - get_global_mouse_position()
		z_index = 10
		modulate = Color.WHITE  # reset from hover when dragging starts
		
	elif event.is_action_released("click"):
		is_dragging = false
		z_index = 0
		var overlapping = $Area2D.get_overlapping_areas()
		
		for area in overlapping:
			if area.name == "PatientArea":
				
				var pentagram = await get_parent().sell_potion(potencies)
				queue_free()

	if event.is_action_pressed("right_click"):
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.08)
		tween.tween_property(self, "scale", Vector2.ZERO, 0.12).set_ease(Tween.EASE_IN)
		tween.tween_callback(queue_free)	

func _on_mouse_entered() -> void:
	if not is_dragging:
		modulate = Color(1.4, 1.4, 1.4)  # nice bright hover

func _on_mouse_exited() -> void:
	if not is_dragging:
		modulate = Color.WHITE         # back to normal
