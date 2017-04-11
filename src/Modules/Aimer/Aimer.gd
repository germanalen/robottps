extends KinematicBody




#remote var _target = Vector3()
remote var _rotation_x = 0


func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
#	if is_network_master():
#		lobby.rrset_unreliable(self, "_target", _get_player().get_target())
#		_target = _get_player().get_target()
#	get_node("Head").look_at(_target, get_transform().basis.y)

	if is_network_master():
		if get_tree().is_network_server():
			_rotation_x = _get_player().get_camera_rotation().x
		else:
			rset_unreliable_id(1, "_rotation_x", _get_player().get_camera_rotation().x)
	if get_tree().is_network_server():
		var rotation = Vector3(_rotation_x, 0, 0)
		lobby.rrpc_unreliable1(self, "_set_rotation", rotation)
		_set_rotation(rotation)
	pass

remote func _set_rotation(var rotation):
	get_node("Head").set_rotation(rotation)

func set_player(player):
	get_node("Head/Modules").set_player(player)

func _get_player():
	return get_node("Head/Modules").get_player()

func attach_module(module):
	get_node("Head/Modules").attach_module(module)

func get_configuration():
	var conf_dict = {
	modules = get_node("Head/Modules").get_configurations_array(),
	x = get_translation().x,
	y = get_translation().y,
	z = get_translation().z
	}
	return conf_dict.to_json()

func parse_configuration(conf):
	var conf_dict = {}
	conf_dict.parse_json(conf)
	
	get_node("Head/Modules").parse_configurations_array(conf_dict.modules)
	
	set_translation(Vector3(conf_dict.x, conf_dict.y, conf_dict.z))