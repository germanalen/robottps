extends Node


func _ready():
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_network_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


var player_packed = preload('res://src/Player/Player.tscn')


func host_server(port):
	_new_game()
	var host = NetworkedMultiplayerENet.new()
	host.create_server(port, 4)
	get_tree().set_network_peer(host)
	_register_player(1, get_random_player_conf())

func connect_to_server(ip, port):
	debugprint.debugprint('Trying to connect...')
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, port)
	get_tree().set_network_peer(host)

func _connected_to_server():
	debugprint.debugprint('Connected to server')
	call_deferred("_deferred_connected_to_server")

func _deferred_connected_to_server():
	_new_game()
	rpc_id(1, '_register_player', get_tree().get_network_unique_id(), get_random_player_conf())

# client's function
func _connection_failed():
	debugprint.debugprint('Connection failed')
	call_deferred("change_to_main_menu")


func _network_peer_connected(id):
	debugprint.debugprint(id, ' connected')


func _network_peer_disconnected(id):
	debugprint.debugprint(id, ' disconnected')
	if get_tree().is_network_server():
		rpc('_remove_player', id)
		_remove_player(id)

func _server_disconnected():
	debugprint.debugprint('server disconnected')
	call_deferred("change_to_main_menu")



func _new_game():
	_ready_player_ids.clear()
	get_tree().get_current_scene().free()
	var game_packed_scene = load('res://src/Game/Game.tscn')
	var game_scene = game_packed_scene.instance()
	get_tree().get_root().add_child(game_scene)
	get_tree().set_current_scene(game_scene)




# server's function
remote func _register_player(id, player_conf):
	for player in get_node('/root/Game/Players').get_children():
		rpc_id(id, '_add_player', player.get_configuration())
	rpc('_add_player', player_conf)


var _ready_player_ids = []

sync func _add_player(player_conf):
	var player = player_packed.instance()
	player.parse_configuration(player_conf)
	
	if player.get_name() == str(get_tree().get_network_unique_id()):
		player.set_network_mode(NETWORK_MODE_MASTER)
	else:
		player.set_network_mode(NETWORK_MODE_SLAVE)
	
	get_node('/root/Game/Players').add_child(player)
	_ready_player_ids.append(int(player.get_name()))

remote func _remove_player(id):
	_ready_player_ids.erase(id)
	get_node('/root/Game/Players/' + str(id)).queue_free()


func get_random_player_conf():
	var player = player_packed.instance()
	randomize()
	player.set_translation(Vector3(rand_range(-20, 20), 0, rand_range(-20, 20)))
	player.set_name(str(get_tree().get_network_unique_id()))
	
	var hexapod = load("res://src/Modules/Hexapod/Hexapod.tscn").instance()
	player.set_root_module(hexapod)
	var aimer = load("res://src/Modules/Aimer/Aimer.tscn").instance()
	aimer.set_translation(Vector3(0,2,0))
	hexapod.get_modules().attach_module(aimer)
	var machine_gun = load("res://src/Modules/MachineGun/MachineGun.tscn").instance()
	machine_gun.set_translation(Vector3(0,1.5,0))
	aimer.get_modules().attach_module(machine_gun)
	
	
	var conf = player.get_configuration()
	player.free()
	return conf



func change_to_main_menu():
	get_tree().set_network_peer(null)
	get_tree().change_scene('res://src/MainMenu/MainMenu.tscn')



func rrset_unreliable(node, property, val):
	for id in _ready_player_ids:
		if id != get_tree().get_network_unique_id():
			node.rset_unreliable_id(id, property, val)

func rrpc_unreliable0(node, method):
	for id in _ready_player_ids:
		if id != get_tree().get_network_unique_id():
			node.rpc_unreliable_id(id, method)

func rrpc_unreliable1(node, method, arg1):
	for id in _ready_player_ids:
		if id != get_tree().get_network_unique_id():
			node.rpc_unreliable_id(id, method, arg1)

func rrpc_unreliable2(node, method, arg1, arg2):
	for id in _ready_player_ids:
		if id != get_tree().get_network_unique_id():
			node.rpc_unreliable_id(id, method, arg1, arg2)

func rrpc_unreliable3(node, method, arg1, arg2, arg3):
	for id in _ready_player_ids:
		if id != get_tree().get_network_unique_id():
			node.rpc_unreliable_id(id, method, arg1, arg2, arg3)

func rrpc_unreliable4(node, method, arg1, arg2, arg3, arg4):
	for id in _ready_player_ids:
		if id != get_tree().get_network_unique_id():
			node.rpc_unreliable_id(id, method, arg1, arg2, arg3, arg4)


func rrpc0(node, method):
	for id in _ready_player_ids:
		if id != get_tree().get_network_unique_id():
			node.rpc_id(id, method)

func rrpc1(node, method, arg1):
	for id in _ready_player_ids:
		if id != get_tree().get_network_unique_id():
			node.rpc_id(id, method, arg1)

func rrpc2(node, method, arg1, arg2):
	for id in _ready_player_ids:
		if id != get_tree().get_network_unique_id():
			node.rpc_id(id, method, arg1, arg2)

func rrpc3(node, method, arg1, arg2, arg3):
	for id in _ready_player_ids:
		if id != get_tree().get_network_unique_id():
			node.rpc_id(id, method, arg1, arg2, arg3)

func rrpc4(node, method, arg1, arg2, arg3, arg4):
	for id in _ready_player_ids:
		if id != get_tree().get_network_unique_id():
			node.rpc_id(id, method, arg1, arg2, arg3, arg4)