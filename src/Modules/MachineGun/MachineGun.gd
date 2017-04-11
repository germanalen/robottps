extends KinematicBody



func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	
	pass


func set_player(player):
	pass

func attach_module(module):
	pass

func get_configuration():
	var conf_dict = {
	x = get_translation().x,
	y = get_translation().y,
	z = get_translation().z
	}
	
	return conf_dict.to_json()

func parse_configuration(conf):
	var conf_dict = {}
	conf_dict.parse_json(conf)
	
	set_translation(Vector3(conf_dict.x, conf_dict.y, conf_dict.z))