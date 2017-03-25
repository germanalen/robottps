extends KinematicBody


func _ready():

	pass



func bend(angle):
	var chest = get_node("Chest")
	var chest_rotation = chest.get_rotation()
	chest_rotation.x = angle
	chest.set_rotation(chest_rotation)




func get_configuration():
	var conf_dict = {
	chest_angle = get_node("Chest").get_rotation().x,
	x = get_translation().x,
	y = get_translation().y,
	z = get_translation().z
	}
	return conf_dict.to_json()


func parse_configuration(conf):
	var conf_dict = {}
	conf_dict.parse_json(conf)
	get_node("Chest").set_rotation(Vector3(conf_dict.chest_angle, 0, 0))
	
	set_translation(Vector3(conf_dict.x, conf_dict.y, conf_dict.z))