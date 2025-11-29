extends Node2D

@onready var herb_description_label = $HerbDescription
@onready var sfx_page_flip: AudioStreamPlayer = $SfxPageFlip
@onready var sfx_page_flip_back: AudioStreamPlayer = $SfxPageFlipBack

var current_page = 0

var herb_mappings_json_path = "res://data/herb_mapping.json"
var herb_mappings = null

@onready var herb_textures = {
	"Lagundi": preload("res://assets/workstation/herbs/herb_lagundi.png"),
	"Root": preload("res://assets/workstation/herbs/herb_root.png"),
	"Bark": preload("res://assets/workstation/herbs/herb_bark.png"),
	"Sampaguita": preload("res://assets/workstation/herbs/herb_sampaguita.png"),
	"Dugo": preload("res://assets/workstation/herbs/herb_dugo.png"),
	"Ginhawa": preload("res://assets/workstation/herbs/herb_ginhawa.png"),
}

var herbal_descriptions = [
	[
		"[fill]A common herbal remedy [color=#1a110a]known to treat ",
		"[/color] when brewed into soothing teas."
	],
	[
		"[fill]A fiery root [color=#1a110a]known to cure ",
		"[/color] by restoring warmth and vigor."
	],
	[
		"[fill]A sacred bark [color=#1a110a]believed to heal ",
		"[/color] when used in protective balms or baths."
	],
	[
		"[fill]A fragrant blossom [color=#1a110a]known to ease ",
		"[/color] when steeped into calming aromatics."
	],
	[
		"[fill]A vivid berry [color=#1a110a]said to restore ",
		"[/color] through revitalizing tonics and salves."
	],
	[
		"[fill]A gentle seed [color=#1a110a]credited with relieving ",
		"[/color] when its soothing oils are extracted."
	]
]


func make_description(idx: int):
	var symptoms = []

	for symptom in herb_mappings["herbs"][herb_textures.keys()[idx]]["symptoms"]:
		if herb_mappings["herbs"][herb_textures.keys()[idx]]["symptoms"][symptom]["type"] == "Primary":
			symptoms.append(symptom.replace("_", " "))

	var final_string = ""
	var count = symptoms.size()

	if count == 1:
		final_string = symptoms[0]
	elif count == 2:
		final_string = symptoms[0] + " and " + symptoms[1]
	else:
		final_string = ", ".join(symptoms.slice(0, count - 1))
		final_string += ", and " + symptoms[count - 1]

	final_string = herbal_descriptions[idx][0] + final_string + herbal_descriptions[idx][1]
	return final_string
	
func to_title(text: String) -> String:
	var words = text.replace("_", " ").split(" ")
	for i in range(words.size()):
		words[i] = words[i].capitalize()
	return " ".join(words)
	
func make_herb_interactions(idx: int):
	var primary_symptoms = []
	var secondary_symptoms = []
	
	for symptom in herb_mappings["herbs"][herb_textures.keys()[idx]]["symptoms"]:
		if herb_mappings["herbs"][herb_textures.keys()[idx]]["symptoms"][symptom]["type"] == "Primary":
			primary_symptoms.append(to_title(symptom.replace("_", " ")))
		if herb_mappings["herbs"][herb_textures.keys()[idx]]["symptoms"][symptom]["type"] == "Secondary":
			secondary_symptoms.append(to_title(symptom.replace("_", " ")))
	
	var final_string = "[color=#1a110a]Known to cure...[/color]\n"
	for primary_symptom in primary_symptoms:
		final_string += " - " + primary_symptom + "\n"
	
	final_string += "\n[color=#1a110a]Also soothes...[/color]\n"
	
	for secondary_symptom in secondary_symptoms:
		final_string += " - " + secondary_symptom + "\n"
	
	return final_string
	
func load_herb_mappings():
	var file = FileAccess.open(herb_mappings_json_path, FileAccess.READ)
	var json_string = file.get_as_text()

	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		print("Failed to parse JSON: ", json.get_error_message())
		return

	herb_mappings = json.get_data()

func change_page(idx: int):	
	$HerbName.text = herb_textures.keys()[idx]
	$HerbTexture.texture = herb_textures[herb_textures.keys()[idx]]
	$HerbDescription.text = make_description(idx)
	$HerbInteractions.text = make_herb_interactions(idx)

func _ready():
	
	$ManualPageFlipButtons/ManualNext.page_next.connect(_page_next)
	$ManualPageFlipButtons/ManualBack.page_back.connect(_page_back)
	load_herb_mappings()
	
	change_page(0)
	
	#herb_description_label.text = "[color=red]Your brown text here[/color]"

func _page_next():
	
	if current_page < herb_textures.size() - 1:
		sfx_page_flip.play()
		current_page += 1
		change_page(current_page)
		
func _page_back():
	
	if current_page > 0:
		sfx_page_flip_back.play()
		current_page -= 1
		change_page(current_page)
