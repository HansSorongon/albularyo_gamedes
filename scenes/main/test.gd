extends Node2D

func _ready():
	$Area2D.mouse_entered.connect(_test)
	
func _test():
	print("test")
