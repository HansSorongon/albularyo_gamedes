extends Node2D

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
	"Male": "res://assets/npc/npc_m/",
	"Female": "res://assets/npc/npc_f/"
}

var npc_instance: Node2D = null

func generate_random_npc() -> Node2D:
	var npc = Node2D.new()
	npc.z_index = 1
	npc.position = Vector2(32, 32)

	var random_gender = gender_folders.keys()[randi() % 2]
	var base_folder = gender_folders[random_gender]
	
	for layer_name in layers.keys():
		var sprite = Sprite2D.new()
		sprite.name = layer_name
		sprite.texture = get_random_texture_from_folder(base_folder + layers[layer_name])
		
		npc.add_child(sprite)
		
	return npc

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

func _ready():
	randomize()
	
	npc_instance = generate_random_npc()
	add_child(npc_instance)
