extends KinematicBody


remote var _input_shoot = false


func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	if is_network_master():
		if get_tree().is_network_server():
			_input_shoot = Input.is_mouse_button_pressed(BUTTON_LEFT)
		else:
			rset_unreliable_id(1, "_input_shoot", Input.is_mouse_button_pressed(BUTTON_LEFT))
	
	if get_tree().is_network_server():
		var timer = get_node("Timer")
		if _input_shoot && timer.get_time_left() <= 0:
			timer.start()
			var raycast = get_node("RayCast")
			if raycast.is_colliding():
				var collider = raycast.get_collider()
				if collider:
					if collider.has_method("get_health"):
						collider.get_health().deal_damage(1)


func set_player(player):
	pass

#func attach_module(module):
#	pass
#


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


func get_health():
	return get_node("Health")