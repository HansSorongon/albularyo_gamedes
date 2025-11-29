extends Node2D

@onready var area := $Area2D
@onready var sfx_bottle: AudioStreamPlayer = $SfxBottle
@onready var sfx_bottle_drop: AudioStreamPlayer = $SfxBottleDrop
@onready var sfx_bottle_ground: AudioStreamPlayer2D = $SfxBottleGround

var is_dragging := false
var drag_offset := Vector2.ZERO

var velocity := Vector2.ZERO
var gravity := 980.0
var is_falling = false
var original_position

var potencies = {}

func random_color_vec4() -> Vector4:
	return Vector4(randf(), randf(), randf(), 1.0)

func _ready() -> void:
	z_index = 10
	original_position = position
	add_to_group("potion")
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)
	
	$BottleInside.material.set_shader_parameter("night_tint", random_color_vec4())

func _process(delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset
		velocity = Vector2.ZERO 
	elif is_falling:
		velocity.y += gravity * delta
		global_position += velocity * delta
		
		if global_position.y >= original_position.y:
			sfx_bottle_ground.play()
			is_falling = false
			velocity = Vector2.ZERO

func _on_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		sfx_bottle.play()
		is_dragging = true
		is_falling = false
		drag_offset = global_position - get_global_mouse_position()

		modulate = Color.WHITE
		
	elif event.is_action_released("click"):
		if position.y < original_position.y - 50:
			sfx_bottle_drop.play()
		is_dragging = false
		is_falling = true
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
