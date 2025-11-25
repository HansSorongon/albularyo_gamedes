extends Node2D

var occupied_zones = {
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
	
func occupy_zone(zone: String, herb_sprite: Sprite2D):
	occupied_zones[zone] = herb_sprite
	
func remove_herb(zone):
	
	if occupied_zones[zone]:
		var herb_sprite = occupied_zones[zone]
		if herb_sprite.is_inside_tree():
			herb_sprite.queue_free()
		occupied_zones[zone] = null
