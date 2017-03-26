extends Spatial



func _ready():
	get_node("GroundRayCast").add_exception(self)
	set_process(true)
	set_process_input(true)
	
	if is_network_master():
		get_node("Camera").make_current()
	get_node("Camera/AimRayCast").add_exception(self)


func _process(delta):
	
	pass


func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var sensitivity = -0.001
		var camera = get_node("Camera")
		var camera_rotation = camera.get_rotation()
		camera_rotation.x = clamp(camera_rotation.x + event.relative_y * sensitivity, -PI*0.45, PI*0.45);
		camera.set_rotation(camera_rotation)

func is_on_ground():
	return get_node("GroundRayCast").is_colliding()

func get_steepness():
	return get_node("GroundRayCast").get_collision_normal().angle_to(Vector3(0, 1, 0)) 

# works only on master
func get_target():
	var aim_raycast = get_node("Camera/AimRayCast")
	if aim_raycast.is_colliding():
		return aim_raycast.get_collision_point()
	else:
		return aim_raycast.get_global_transform().basis * aim_raycast.get_cast_to()


func get_configuration():
	var conf_dict = {
	name = get_name(), 
	x = get_translation().x,
	y = get_translation().y,
	z = get_translation().z}
	return conf_dict.to_json()

func parse_configuration(conf):
	var conf_dict = {}
	conf_dict.parse_json(conf)
	set_name(conf_dict.name)
	set_translation(Vector3(conf_dict.x, conf_dict.y, conf_dict.z))
	
	
	
	var locomotor = load("res://src/Modules/Hexapod/Hexapod.tscn").instance()
	locomotor.set_player(self)
	
	
	var aimer = load("res://src/Modules/Aimer/Aimer.tscn").instance()
	aimer.set_player(self)
	aimer.set_translation(Vector3(0,2,0))
	locomotor.add_child(aimer)
	
	add_child(locomotor)
