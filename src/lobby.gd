extends Node


func _ready():
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_network_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")



func host_server(port):
	get_tree().change_scene('res://src/Game/Game.tscn')
	var host = NetworkedMultiplayerENet.new()
	host.create_server(port, 4)
	get_tree().set_network_peer(host)

func connect_to_server(ip, port):
	debugprint.debugprint('Trying to connect...')
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, port)
	get_tree().set_network_peer(host)

func _connected_to_server():
	debugprint.debugprint('Connected to server')
	get_tree().change_scene('res://src/Game/Game.tscn')

func _connection_failed():
	debugprint.debugprint('Connection failed')
	get_tree().set_network_peer(null)



func _network_peer_connected(id):
	debugprint.debugprint(id, ' connected')
	pass

func _network_peer_disconnected(id):
	debugprint.debugprint(id, ' disconnected')
	pass

func _server_disconnected():
	debugprint.debugprint('server disconnected')
	pass
