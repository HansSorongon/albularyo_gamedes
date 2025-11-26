extends Node2D

@onready var sfx_burn: AudioStreamPlayer = $SfxBurn
@onready var sfx_remove: AudioStreamPlayer = $SfxRemove
@onready var sfx_poof: AudioStreamPlayer = $SfxPoof
var burn_material: ShaderMaterial = preload("res://shaders/burn_mat.tres")

var herb_mappings_json_path = "res://data/herb_mapping.json"
var herb_mappings: Dictionary

var occupied_zones = {
	"PentagramPoint1": null,
	"PentagramPoint2": null,
	"PentagramPoint3": null,
	"PentagramPoint4": null,
	"PentagramPoint5": null,
	"PentagramPoint6": null
}

var occupied_names = {
	"PentagramPoint1": null,
	"PentagramPoint2": null,
	"PentagramPoint3": null,
	"PentagramPoint4": null,
	"PentagramPoint5": null,
	"PentagramPoint6": null
}

var potencies: Dictionary = {}

signal changed_potency()

func _ready():
	load_herb_mappings()
	
	$PentagramConfirm.confirm_pressed.connect(_confirm_craft)
	
func is_zone_occupied(zone) -> bool:
	return occupied_zones.has(zone) and occupied_zones[zone] != null

func destroy_herbs() -> void:
	var herb_container = get_node("HerbSprites")
	var herbs = herb_container.get_children()
	
	# If nothing to burn → just clear immediately
	if herbs.is_empty():
		_clear_all_zones()
		return
	
	# Play burn SFX once at the start
	sfx_burn.play()
	
	var herbs_to_burn: int = 0
	for child in herbs:
		if not child or not child is Sprite2D:
			continue
			
		herbs_to_burn += 1
		
		# Make sure it has its own material instance
		if child.material and child.material is ShaderMaterial:
			child.material = child.material.duplicate()  # Important!
		else:
			child.material = burn_material.duplicate()
		
		# Reset progress to -1.5 or 0 so the burn starts fresh
		child.material.set_shader_parameter("progress", -1.5)
		
		# Create a tween for this herb
		var tween = create_tween()
		tween.set_parallel(false)  # We want finished signal after all its tweens
		
		# Burn animation
		tween.tween_property(
			child.material,
			"shader_parameter/progress",
			1.5,
			1.8  # Slightly longer than before for nice overlap
		).set_ease(Tween.EASE_IN)
		
		# When THIS herb finishes burning → check if all are done
		tween.tween_callback(func():
			herbs_to_burn -= 1
			if herbs_to_burn <= 0:
				_clear_all_zones()
		)
	
	# If somehow zero valid herbs, clear immediately
	if herbs_to_burn == 0:
		_clear_all_zones()


# Helper function — put your zone clearing logic here
func _clear_all_zones() -> void:
	for zone in occupied_zones.keys():
		if occupied_zones[zone]:
			remove_herb(zone)
	
	# Optional: clear the container too
	for child in get_node("HerbSprites").get_children():
		child.queue_free()

func occupy_zone(zone: String, herb_sprite: Sprite2D, herb_name: String):
	
	occupied_zones[zone] = herb_sprite
	occupied_names[zone] = herb_name
	change_potency()
	
	var node = get_node(zone)
	if node:
		node.get_node("CollisionShape2D").apply_scale(Vector2(1, 2))
	
func remove_herb(zone):
	
	if occupied_zones[zone]:
		
		var herb_sprite = occupied_zones[zone]
		if herb_sprite.is_inside_tree():
			herb_sprite.queue_free()
		occupied_zones[zone] = null
		occupied_names[zone] = null
		change_potency()
		
		var node = get_node(NodePath(zone))
		if node:
			node.get_node("CollisionShape2D").apply_scale(Vector2(1, 0.5))

func load_herb_mappings():
	var file = FileAccess.open(herb_mappings_json_path, FileAccess.READ)
	var json_string = file.get_as_text()

	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		print("Failed to parse JSON: ", json.get_error_message())
		return

	herb_mappings = json.get_data()

func change_potency():
	
	potencies.clear()
	
	var catalyst = occupied_names["PentagramPoint6"]
	
	if catalyst:
		for symptom in herb_mappings["herbs"][catalyst]["symptoms"]:
			#if herb_mappings["herbs"][catalyst]["symptoms"][symptom]["type"] == "Primary":
			potencies[symptom] = potencies.get(symptom, 0) + herb_mappings["herbs"][catalyst]["symptoms"][symptom]["soloValue"]
			
		for point in occupied_names.keys():
			if point == "PentagramPoint6":
				continue
				
			var current_herb = occupied_names[point]

			if current_herb:
				
				if current_herb == catalyst:
					continue
				
				for symptom in herb_mappings["herbs"][current_herb]["symptoms"]:
					if herb_mappings["herbs"][current_herb]["symptoms"][symptom]["type"] == "Secondary":
						#print(herb_mappings["herbs"][current_herb]["symptoms"][symptom])q
						potencies[symptom] = potencies.get(symptom, 0) + herb_mappings["herbs"][current_herb]["symptoms"][symptom]["interactions"][catalyst]
		
	changed_potency.emit()

func _confirm_craft():
	
	destroy_herbs()
	
	if not occupied_zones["PentagramPoint6"]:
		MessageManager.show_message("No catalyst selected!")
		return
		
	sfx_poof.play()
	$ExplosionParticles.restart()
		
	print(potencies)
