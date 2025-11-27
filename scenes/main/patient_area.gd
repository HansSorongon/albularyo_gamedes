extends Area2D

#@onready var my_area := self

func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	if event.is_action_released("click"):
		print("test")
		#is_dragging = false
		#z_index = 0
		#
		## Check collision ONLY on drop
		#for area in get_overlapping_areas():
			#if area.is_in_group("trash_bin"):
				#print("Dropped in trash! Deleting...")
				#queue_free()
				#return
			#if area.name == "Cauldron":
				#print("Dropped in cauldron! Brewing...")
				# do something
