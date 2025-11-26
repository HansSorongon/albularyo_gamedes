extends Node2D

@onready var sfx_remove: AudioStreamPlayer = $SfxRemove

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
	pass
	
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
