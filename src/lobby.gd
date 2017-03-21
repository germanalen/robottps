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
	_register_player(get_random_player_conf())

func connect_to_server(ip, port):
	debugprint.debugprint('Trying to connect...')
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, port)
	get_tree().set_network_peer(host)

func _connected_to_server():
	debugprint.debugprint('Connected to server')
	_new_game()
	rpc_id(1, '_register_player', get_random_player_conf())

# client's function
func _connection_failed():
	debugprint.debugprint('Connection failed')
	get_tree().set_network_peer(null)
	get_tree().change_scene('res://src/MainMenu/MainMenu.tscn')


func _network_peer_connected(id):
	debugprint.debugprint(id, ' connected')
	if get_tree().is_network_server():
		for player in get_node('/root/Game/Players').get_children():
			rpc_id(id, '_add_player', player.get_configuration())


func _network_peer_disconnected(id):
	debugprint.debugprint(id, ' disconnected')
	if get_tree().is_network_server():
		rpc('_remove_player', id)

func _server_disconnected():
	debugprint.debugprint('server disconnected')
	get_tree().set_network_peer(null)
	get_tree().change_scene('res://src/MainMenu/MainMenu.tscn')



func _new_game():
	get_tree().get_current_scene().free()
	var game_packed_scene = load('res://src/Game/Game.tscn')
	var game_scene = game_packed_scene.instance()
	get_tree().get_root().add_child(game_scene)
	get_tree().set_current_scene(game_scene)

# server's function
remote func _register_player(player_conf):
	rpc('_add_player', player_conf)

sync func _add_player(player_conf):
	var player = player_packed.instance()
	player.parse_configuration(player_conf)
	get_node('/root/Game/Players').add_child(player)

sync func _remove_player(id):
	get_node('/root/Game/Players/' + str(id)).queue_free()


func get_random_player_conf():
	var player = player_packed.instance()
	randomize()
	player.set_translation(Vector3(rand_range(-20, 20), 0, rand_range(-20, 20)))
	player.set_name(str(get_tree().get_network_unique_id()))
	var conf = player.get_configuration()
	player.free()
	return conf