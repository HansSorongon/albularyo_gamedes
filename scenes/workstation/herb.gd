extends Sprite2D

@export var herb_name: String = "Lagundi"
@onready var sfx_click: AudioStreamPlayer = $sfx_click
@onready var sfx_click_2: AudioStreamPlayer = $sfx_click_2

var hover_color := Color(1.2, 1.2, 1.2, 1)
var normal_color := Color(1, 1, 1, 1)

var is_dragging: bool = false
var original_position: Vector2
var original_scale: Vector2

func _ready():
	
	original_position = position
	original_scale = $ClickTarget/CollisionShape2D.scale
	
	$ClickTarget.input_event.connect(_on_click_target_input)
	$ClickTarget.mouse_entered.connect(_on_mouse_entered)
	$ClickTarget.mouse_exited.connect(_on_mouse_exited)
	
func _process(delta):
	if is_dragging:
		var mouse_pos = get_global_mouse_position()
		position = mouse_pos
	
func _on_click_target_input(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		sfx_click.play()
		is_dragging = true
		$ClickTarget/CollisionShape2D.scale = Vector2(0.5, 0.5)
	elif event.is_action_released("click"):
		sfx_click_2.play()
		is_dragging = false
		_check_drop_target()
		#position = original_position

func _check_drop_target():
	var overlapping_areas = $ClickTarget.get_overlapping_areas()
	$ClickTarget/CollisionShape2D.scale = original_scale
	var dropped_successfully = false
	
	var pentagram = get_parent().get_parent().get_node("Pentagram")
	
	for area in overlapping_areas:
		if area.is_in_group("pentagram_drop_zone"):
			
			var zone = area.name
			if pentagram.is_zone_occupied(zone):
				continue
			
			var new_herb = Sprite2D.new()
			new_herb.texture = texture
			new_herb.position = area.global_position
			get_parent().add_child(new_herb)
			pentagram.occupy_zone(zone, new_herb)
			
			break
			
	position = original_position

func _on_mouse_entered():
	modulate = hover_color
	
func _on_mouse_exited():
	modulate = normal_color
