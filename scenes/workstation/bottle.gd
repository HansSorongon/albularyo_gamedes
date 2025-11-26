extends Node2D

@export var particle: PackedScene

func _ready():
	var _particle = particle.instance()
	_particle.position = global_position
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
