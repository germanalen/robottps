extends KinematicBody 

var _player = null
func set_player(player):
	_player = player
 
# input
var _move_direction = Vector3() # server

var _rotation_y = 0 # input & state for client, input for server
 
# state
var _velocity = Vector3() # server

var _server_translation = Vector3() # client
var _server_rotation_y = 0 # client
 
 
func _ready(): 
	set_process_input(true) 
	set_fixed_process(true) 
 
 
func _fixed_process(delta): 
	if get_tree().is_network_server(): 
		_server_update(delta)
	else:
		_client_update(delta) 
#	if is_network_master(): 
#		_local_update(delta) 
 
 
func _input(event):
	if is_network_master(): 
		_local_input(event) 
 
 
func _server_update(delta): 
	_move_direction = _move_direction.normalized() 
	var speed = 20 
	_velocity.x = 0 
	_velocity.z = 0 
	_velocity.y -= 40 * delta 
	if _player.is_on_ground() && _player.get_steepness() < 1: 
		_velocity.x = _move_direction.x * speed 
		_velocity.z = _move_direction.z * speed 
	 
	var motion = _player.get_transform().basis * _velocity * delta 
	var remainder = _player.move(motion) 
	if _player.is_colliding(): 
		var collision_normal = _player.get_collision_normal() 
		motion = collision_normal.slide(remainder) 
		_velocity = collision_normal.slide(_velocity) 
		_player.move(motion) 
	
	
	_player.set_rotation(Vector3(0, _rotation_y, 0))
	#This doesn't work because of the nature of euler angles
#	var rotation = _player.get_rotation()
#	rotation.y = _rotation_y
#	_player.set_rotation(Vrotation)
	
	rpc_unreliable('_set_client_state', _player.get_translation(), _rotation_y) 
 
 
remote func _set_server_input(move_direction, rotation_y): 
	_move_direction = move_direction 
	_rotation_y = rotation_y 
 
remote func _set_client_state(server_translation, server_rotation_y):
	_server_translation = server_translation
	_server_rotation_y = server_rotation_y


func _client_update(delta): 
	var translation = _player.get_translation() 
	var weight = 50 
	translation.x = lerp(translation.x, _server_translation.x, delta * weight) 
	translation.y = lerp(translation.y, _server_translation.y, delta * weight) 
	translation.z = lerp(translation.z, _server_translation.z, delta * weight) 
	_player.set_translation(translation) 
	 
#	_slerp_rotation(_player, _player.get_transform().basis.y, _server_rotation_y, 50)
	_rotation_y = lerp(_rotation_y, _server_rotation_y, 10 * delta)
	_player.set_rotation(Vector3(0, _rotation_y, 0))

 
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
		var sensitivity = -0.003
		_rotation_y = fmod(_rotation_y + event.relative_x * sensitivity, PI * 2)
	
	if get_tree().is_network_server(): 
		_set_server_input(move_direction, _rotation_y) 
	else: 
		rpc_unreliable_id(1, '_set_server_input', move_direction, _rotation_y) 
 
 
func _slerp_rotation(spatial, axis, rotation, weight): 
	var transform = spatial.get_transform() 
	transform.basis = Matrix3(Quat(transform.basis).slerp(Quat(axis, rotation), weight)) 
	spatial.set_transform(transform) 
 
 
func get_configuration(): 
	var conf_dict = {}
	return conf_dict.to_json() 
 
func parse_configuration(conf): 
	var conf_dict = {} 
	conf_dict.parse_json(conf) 