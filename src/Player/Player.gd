extends KinematicBody



func _ready():
	get_node("GroundRayCast").add_exception(self)
	set_fixed_process(true)
	set_process_input(true)
	
	if is_network_master():
		get_node("CameraController/Camera").make_current()
	get_node("CameraController/Camera/AimRayCast").add_exception(self)


func _fixed_process(delta):
	if get_tree().is_network_server():
		var root_module = _get_root_module()
		if !root_module:
			die_deferred()
			lobby.rrpc0(self, "die_deferred")
	pass


func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var sensitivity = -0.001
		var camera = get_node("CameraController")
		var camera_rotation = camera.get_rotation()
		camera_rotation.x = clamp(camera_rotation.x + event.relative_y * sensitivity, -PI*0.45, PI*0.45);
		camera.set_rotation(camera_rotation)

func is_on_ground():
	return get_node("GroundRayCast").is_colliding()

func get_steepness():
	return get_node("GroundRayCast").get_collision_normal().angle_to(Vector3(0, 1, 0)) 

## works only on master
#func get_target():
#	var aim_raycast = get_node("CameraController/Camera/AimRayCast")
#	if aim_raycast.is_colliding():
#		return aim_raycast.get_collision_point()
#	else:
#		return aim_raycast.get_global_transform().basis * aim_raycast.get_cast_to()

func get_camera_rotation():
	return get_node("CameraController").get_rotation()


func set_root_module(module):
	var root_module = _get_root_module()
	if root_module:
		remove_child(root_module)
		root_module.free()
	module.set_name("RootModule")
	module.set_player(self)
	add_child(module)

func _get_root_module():
	return find_node("RootModule", false, false)


func get_configuration():
	var conf_dict = {
	name = get_name(), 
	x = get_translation().x,
	y = get_translation().y,
	z = get_translation().z
	}
	var root_module = _get_root_module()
	if root_module:
		conf_dict["root_module_scene"] = root_module.get_filename()
		conf_dict["root_module_conf"] = root_module.get_configuration()
	
	return conf_dict.to_json()

func parse_configuration(conf):
	var conf_dict = {}
	conf_dict.parse_json(conf)
	set_name(conf_dict.name)
	set_translation(Vector3(conf_dict.x, conf_dict.y, conf_dict.z))
	
	if conf_dict.has("root_module_scene"):
		var root_module = load(conf_dict.root_module_scene).instance()
		set_root_module(root_module)
		root_module.parse_configuration(conf_dict.root_module_conf)
	
	
#	var locomotor = load("res://src/Modules/Hexapod/Hexapod.tscn").instance()
#	locomotor.set_player(self)
#	deferred_set_root_module(locomotor)
#	var aimer = load("res://src/Modules/Aimer/Aimer.tscn").instance()
#	aimer.set_player(self)
#	aimer.set_translation(Vector3(0,2,0))
#	locomotor.attach_module(aimer)
#	var machine_gun = load("res://src/Modules/MachineGun/MachineGun.tscn").instance()
#	machine_gun.set_player(self)
#	machine_gun.set_translation(Vector3(0, 0.5, 0))
#	aimer.attach_module(machine_gun)
	
	

remote func die_deferred():
	call_deferred("die")

func die():
	set_layer_mask(0)
	if is_network_master():
		get_node("/root/Game/Camera").make_current()