extends Node2D

var dialogue_symptoms: Dictionary = {
	"chest_pain": ["My chest feels tight.", "It hurts when I breathe deeply.", "I feel heaviness on my chest."],
	"cough": ["My cough keeps coming back.", "My cough gets worse at night.", "I've been coughing for a month now."],
	"sore_throat": ["It's painful when I swallow.", "My throat is hoarse.", "It's hard to speak."],
	"headache": ["My head hurts when I wake up.", "My head is throbbing.", "It feels like the world is spinning."]
}

# Cached data from the JSON file
var symptom_sets_by_size: Dictionary = {}
var json_loaded: bool = false

# Weights for each symptom count
var symptom_size_weights := {
	1: 0.05,
	2: 0.35,
	3: 0.45,
	4: 0.10,
	5: 0.05,
}
#sizes of each symptom
const SYMPTOM_SIZES := [1, 2, 3, 4, 5]

var visual_symptoms: Array[String] = [
	"pale_lips",
	"sweat",
	"fever",
	"sunken_eyes",
	"red_eyes",
	"runny_nose",
	"red_nose",
	"hollow_cheeks",
	"rashes",
	"wound",
]

var symptoms: Array[String] = []
var patient_dialogue: Array[String] = ["Magandang araw, Albularyo."]

var layers = {
	"hair_back": "hair_back/",
	"base_face": "base_face/",
	"eyes": "eyes/",
	"eyebrows": "eyebrows/",
	"hair_front": "hair_front/",
	"clothes": "clothes/",
	"accessories": "accessories/"
}

var layers_num_f = {
	"hair_back": 5,
	"base_face": 9,
	"eyes": 9,
	"eyebrows": 5,
	"hair_front": 11,
	"clothes": 2,
	"accessories": 3
}

var layers_num_m = {
	"hair_back": 3,
	"base_face": 18,
	"eyes": 5,
	"eyebrows": 10,
	"hair_front": 6,
	"clothes": 3,
	"accessories": 3
}

var gender_folders = {
	"m": "res://assets/npc/npc_m/",
	"f": "res://assets/npc/npc_f/"
}

var npc_instance: Node2D = null

func get_random_weighted_symptom_set() -> Array[String]:
	# --- Load JSON once (first call only) ---
	if not json_loaded:
		var file := FileAccess.open("res://data/solvable_symptom_sets.json", FileAccess.READ)
		if file == null:
			push_error("Failed to open solvable_symptom_sets.json")
			return []

		var json_text := file.get_as_text()
		var parsed: Dictionary = JSON.parse_string(json_text)

		if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("by_size"):
			push_error("Invalid JSON format: expected { \"by_size\": ... }")
			return []

		symptom_sets_by_size = parsed["by_size"]
		json_loaded = true

	# --- Weighted random choice over sizes 1–5 in a fixed order ---
	var total_weight := 0.0
	for size in SYMPTOM_SIZES:
		total_weight += symptom_size_weights[size]

	var r := randf() * total_weight
	var cumulative := 0.0
	var chosen_size: int = SYMPTOM_SIZES[-1]	# fallback to last one

	for size in SYMPTOM_SIZES:
		cumulative += symptom_size_weights[size]
		if r <= cumulative:
			chosen_size = size
			break

	# --- Pick a random set from the chosen bucket ---
	var key := str(chosen_size)
	var bucket: Array = symptom_sets_by_size[key]

	if bucket.is_empty():
		push_error("No symptom sets for size %d" % chosen_size)
		return []

	var idx := randi() % bucket.size()
	var chosen: Array = bucket[idx]

	# Convert to Array[String]
	var result: Array[String] = []
	for s in chosen:
		result.append(String(s))

	return result
 
func generate_symptoms():
	symptoms.clear()
	symptoms = get_random_weighted_symptom_set()

func generate_random_npc() -> Node2D:
	var npc = Node2D.new()
	npc.z_index = 1
	npc.position = Vector2(32, 32)

	var random_gender = gender_folders.keys()[randi() % 2]
	var base_folder = gender_folders[random_gender]
	
	for layer_name in layers.keys():
		
		var path = base_folder + layers[layer_name]
		
		if symptoms.has("pale_skin") and layer_name == "base_face":
			if random_gender == "f":
				path += "sprite_F_paleskin/" + "f_paleskin_" + str(randi() % 6 + 1) + ".png"
			elif random_gender == "m":	
				path += "sprite_M_paleskin/" + "m_paleskin_" + str(randi() % 6 + 1) + ".png"
		else:	
			if random_gender == "f":
				path += random_gender + "_" + layer_name + "_" + str(randi() % layers_num_f[layer_name] + 1) + ".png"
			elif random_gender == "m":
				path += random_gender + "_" + layer_name + "_" + str(randi() % layers_num_m[layer_name] + 1) + ".png"
		
		var sprite = Sprite2D.new()
		sprite.name = layer_name
		sprite.texture = load(path)
		sprite.modulate = Color.BLACK
		
		npc.add_child(sprite)
		
	for symptom in symptoms:
		if visual_symptoms.has(symptom):
			var symptom_name = symptom
			if (symptom == "wound"):
				symptom_name += "_" + str(randi() % 2 + 1)
			
			var path = base_folder + "visual_symptoms/" + symptom_name + ".png"

			var sprite = Sprite2D.new()
			sprite.name = symptom
			sprite.texture = load(path)
			sprite.modulate = Color.BLACK
			
			if symptom_name == "fever" or true:
				var base_face = npc.get_node("base_face")
				base_face.add_sibling(sprite)
			else:
				npc.add_child(sprite)
		
		if dialogue_symptoms.has(symptom):
			patient_dialogue.append(dialogue_symptoms[symptom][randi() % dialogue_symptoms[symptom].size()])
			
	return npc

func fade_in_npc(duration: float = 1.0):
	var tween = create_tween()
	tween.set_parallel(true)
	
	for child in npc_instance.get_children():
		if child is Sprite2D:
			tween.tween_property(child, "modulate", Color.WHITE, duration).set_delay(2.0)

func get_random_texture_from_folder(folder_path: String) -> Texture2D:

	var dir = DirAccess.open(folder_path)
	
	var files = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png"):
				files.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	
	if files.size() == 0:
		return null
	
	var chosen_file = files[randi() % files.size()]
	
	return load(folder_path + chosen_file)

func spawn_npc():
	
	generate_symptoms()
	
	if npc_instance and npc_instance.is_inside_tree():
		npc_instance.queue_free()
	
	npc_instance = generate_random_npc()
	add_child(npc_instance)
	fade_in_npc(1)
	
	if not DialogueManager.is_dialog_active:
		DialogueManager.start_dialog(patient_dialogue)
		
	print(symptoms)
	
	# reset path
	get_parent().time = 0

func npc_leave(duration: float = 2.0):
	if not npc_instance or not npc_instance.is_inside_tree():
		return
	
	# Get the PathFollow2D parent
	var path_follow = get_parent()
	
	if path_follow is PathFollow2D:
		var tween = create_tween()
		tween.set_parallel(false)  # Sequential, not parallel
		
		# Move backwards along the path (from current position to 0)
		tween.tween_property(path_follow, "progress_ratio", 0.0, duration)
		
		# Fade out while walking back
		var fade_tween = create_tween()
		fade_tween.set_parallel(true)
		for child in npc_instance.get_children():
			if child is Sprite2D:
				fade_tween.tween_property(child, "modulate", Color.BLACK, duration * 0.8)
		
		await tween.finished
	else:
		# Fallback: just fade if not on a path
		var tween = create_tween()
		tween.set_parallel(true)
		for child in npc_instance.get_children():
			if child is Sprite2D:
				tween.tween_property(child, "modulate", Color.BLACK, duration)
		await tween.finished
	
	if npc_instance and npc_instance.is_inside_tree():
		npc_instance.queue_free()
		npc_instance = null

func _repeat_dialogue():
	if not DialogueManager.is_dialog_active:
		DialogueManager.start_dialog(patient_dialogue)

func _ready():
	
	var root_node = get_tree().current_scene
	root_node.get_node("WorkstationUI/DialogueRepeatButton").pressed.connect(_repeat_dialogue)
	
	randomize()
	spawn_npc()
