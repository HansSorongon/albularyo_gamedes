extends Node2D

@onready var sfx_remove: AudioStreamPlayer = $SfxRemove

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

func _ready():
	load_herb_mappings()
	
	$PentagramConfirm.confirm_pressed.connect(_confirm_craft)
	
func is_zone_occupied(zone) -> bool:
	return occupied_zones.has(zone) and occupied_zones[zone] != null
	
func occupy_zone(zone: String, herb_sprite: Sprite2D, herb_name: String):
	
	occupied_zones[zone] = herb_sprite
	occupied_names[zone] = herb_name
	
	var node = get_node(zone)
	if node:
		node.get_node("CollisionShape2D").apply_scale(Vector2(1, 2))
	
func remove_herb(zone):
	
	if occupied_zones[zone]:
		sfx_remove.play()
		
		var herb_sprite = occupied_zones[zone]
		if herb_sprite.is_inside_tree():
			herb_sprite.queue_free()
		occupied_zones[zone] = null
		occupied_names[zone] = null
		
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

func _confirm_craft():
	
	var potencies: Dictionary = {}
	
	if not occupied_zones["PentagramPoint6"]:
		MessageManager.show_message("No catalyst selected!")
		return
	
	var catalyst = occupied_names["PentagramPoint6"]
	
	#print(herb_mappings["herbs"][catalyst])
	
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
	
	print(potencies)
	#print(herb_mappings["herbs"][catalyst]["symptoms"])
