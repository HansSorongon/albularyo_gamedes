extends Node

var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Bgm"
	add_child(music_player)

func play_music(music_path: String, volume_db: float = 0.0):
	
	if music_player.stream and music_player.stream.resource_path == music_path and music_player.playing:
		return
	
	music_player.stream = load(music_path)
	music_player.volume_db = volume_db
	music_player.play()

func stop_music():
	music_player.stop()

func set_volume(volume_db: float):
	music_player.volume_db = volume_db
