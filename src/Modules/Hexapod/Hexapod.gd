extends KinematicBody


var _move_direction = Vector3() # server
var _rotation_y = 0 # client & server
var _camera_controller_rotation_x = 0 # local

var _velocity = Vector3()


func _ready():
	set_process_input(true)
	set_fixed_process(true)
	get_node("RayCast").add_exception(self)
	if is_network_master():
		var camera = Camera.new()
		camera.set_name("Camera")
		camera.set_translation(Vector3(0, 4, 7))
		camera.make_current()
		var camera_controller = Spatial.new()
		camera_controller.set_name("CameraController")
		camera_controller.add_child(camera)
		add_child(camera_controller)


func _fixed_process(delta):
	if get_tree().is_network_server():
		_server_update(delta)
	if is_network_master():
		_local_update(delta)


func _input(event):
	if is_network_master():
		_local_input(event)


func _server_update(delta):
	var on_ground = false
	if get_node("RayCast").is_colliding():
		var steepness = get_node("RayCast").get_collision_normal().angle_to(Vector3(0, 1, 0))
		on_ground = steepness < 1
	
	_move_direction = _move_direction.normalized()
	var speed = 20
	_velocity.x = 0
	_velocity.z = 0
	if on_ground:
		_velocity.x = _move_direction.x * speed
		_velocity.z = _move_direction.z * speed
	_velocity.y -= 40 * delta
	
	var motion = get_transform().basis * _velocity * delta
	var remainder = move(motion)
	if is_colliding():
		var collision_normal = get_collision_normal()
		motion = collision_normal.slide(remainder)
		_velocity = collision_normal.slide(_velocity)
		move(motion)
	
	rpc_unreliable('_client_update', delta, get_translation(), _rotation_y)


remote func _set_server_input(move_direction, rotation_y):
	_move_direction = move_direction
	_rotation_y = rotation_y



var _key_pressed = {}
func _local_input(event):
	if event.type == InputEvent.KEY:
		_key_pressed[event.scancode] = event.pressed
	
	var move_direction = Vector3(0, 0, 0)
	if _key_pressed.has(KEY_W) && _key_pressed[KEY_W]:
		move_direction.z += -1
	if _key_pressed.has(KEY_S) && _key_pressed[KEY_S]:
		move_direction.z += 1
	if _key_pressed.has(KEY_A) && _key_pressed[KEY_A]:
		move_direction.x += -1
	if _key_pressed.has(KEY_D) && _key_pressed[KEY_D]:
		move_direction.x += 1
	
	if event.type == InputEvent.MOUSE_MOTION:
		var sensitivity_x = 0.001
		var sensitivity_y = 0.001
		
		_camera_controller_rotation_x = clamp(
						_camera_controller_rotation_x + event.relative_y * sensitivity_x, 
						-PI * 0.49, PI * 0.49)
		_rotation_y = fmod(_rotation_y + event.relative_x * sensitivity_y, PI * 2)
	
	if get_tree().is_network_server():
		_set_server_input(move_direction, _rotation_y)
	else:
		rpc_unreliable_id(1, '_set_server_input', move_direction, _rotation_y)



func _local_update(delta):
	_lerp_rotation(get_node("CameraController"), Vector3(1, 0, 0), _camera_controller_rotation_x, 10 * delta)

sync func _client_update(delta, translation_, _rotation_y):
	var translation = get_translation()
	var weight = 50
	translation.x = lerp(translation.x, translation_.x, delta * weight)
	translation.y = lerp(translation.y, translation_.y, delta * weight)
	translation.z = lerp(translation.z, translation_.z, delta * weight)
	set_translation(translation)
	
	_lerp_rotation(self, Vector3(0, 1, 0), _rotation_y, 10*delta)


func _lerp_rotation(spatial, axis, rotation, weight):
	var transform = spatial.get_transform()
	transform.basis = Matrix3(Quat(transform.basis).slerp(Quat(axis, rotation), weight))
	spatial.set_transform(transform)


func get_configuration():
	var conf_dict = {
	x = get_translation().x,
	y = get_translation().y,
	z = get_translation().z
	}
	
	var torso = find_node("Torso", false, false)
	if torso:
		conf_dict["torso_module_scene"] = torso.get_filename()
		conf_dict["torso_module_conf"] = torso.get_configuration()
	
	return conf_dict.to_json()

func parse_configuration(conf):
	var conf_dict = {}
	conf_dict.parse_json(conf)
	set_translation(Vector3(conf_dict.x, conf_dict.y, conf_dict.z))
	
	if conf_dict.has("torso_module_scene"):
		var torso = load(conf_dict.torso_module_scene).instance()
		torso.parse_configuration(conf_dict.torso_module_conf)
		add_child(torso)