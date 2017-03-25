extends Node



func _ready():
	pass


func get_configuration():
	var conf_dict = {
	name = get_name(),
	base_module_scene = get_node('Base').get_filename(),
	base_module_conf = get_node('Base').get_configuration()
	}
	return conf_dict.to_json()

func parse_configuration(conf):
	var conf_dict = {}
	conf_dict.parse_json(conf)
	set_name(conf_dict.name)
	
	var base_module = load(conf_dict.base_module_scene).instance()
	base_module.parse_configuration(conf_dict.base_module_conf)
	add_child(base_module)
	
	var player_shape = CapsuleShape.new()
	player_shape.set_radius(2)
	player_shape.set_height(4)
	var player_shape_transform = Transform(Vector3(1,0,0), Vector3(0,0,1), Vector3(0,1,0), Vector3(0,4,0))
	base_module.add_shape(player_shape)
	base_module.set_shape_transform(base_module.get_shape_count()-1, player_shape_transform)

