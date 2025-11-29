extends Node2D
@onready var bgm_main_menu: AudioStreamPlayer2D = $BgmMainMenu

func _ready():
	#bgm_main_menu.play()
	MusicManager.play_music("res://assets/audio/bgm_menu.ogg")
