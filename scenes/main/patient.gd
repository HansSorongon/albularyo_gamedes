extends Node2D

var dialogue_symptoms: Dictionary = {
	"chest_pain": ["My chest feels tight.", "It hurts when I breathe deeply.", "I feel heaviness on my chest."],
	"cough": ["My cough keeps coming back.", "My cough gets worse at night.", "I've been coughing for a month now."],
	"sore_throat": ["It's painful when I swallow.", "My throat is hoarse.", "It's hard to speak."],
	"headache": ["My head hurts when I wake up.", "My head is throbbing.", "It feels like the world is spinning."]
}

var possible_symptoms: Array[String] = [
	"pale_skin",
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
	"chest_pain",
	"cough",
	"sore_throat",
	"headache"
]

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
	"HairBack": "hair_back/",
	"BaseFace": "base_face/",
	"Eyes": "eyes/",
	"Eyebrows": "eyebrows/",
	"HairFront": "hair_front/",
	"Clothes": "clothes/",
	"Accessories": "accessories/"
}

var gender_folders = {
	"M": "res://assets/npc/npc_m/",
	"F": "res://assets/npc/npc_f/"
}

var npc_instance: Node2D = null

func generate_symptoms():
	symptoms.clear()
	
	# 2-3 symptoms
	var num_symptoms = randi() % 2 + 2
		
	var pool = possible_symptoms.duplicate()
	pool.shuffle()
	
	for i in range(num_symptoms):
		symptoms.append(pool[i])

func generate_random_npc() -> Node2D:
	var npc = Node2D.new()
	npc.z_index = 1
	npc.position = Vector2(32, 32)

	var random_gender = gender_folders.keys()[randi() % 2]
	var base_folder = gender_folders[random_gender]
	
	for layer_name in layers.keys():
		
		var path = base_folder + layers[layer_name]
		
		if symptoms.has("pale_skin") and layer_name == "BaseFace":
			path += "sprite_" + random_gender + "_paleskin/"
		
		var sprite = Sprite2D.new()
		sprite.name = layer_name
		sprite.texture = get_random_texture_from_folder(path)
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
				var base_face = npc.get_node("BaseFace")
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
	#print(root_node.get_node("BookToggle").get_node("DialogueRepeatButton"))
	root_node.get_node("BookToggle/DialogueRepeatButton").pressed.connect(_repeat_dialogue)
	
	randomize()
	spawn_npc()
