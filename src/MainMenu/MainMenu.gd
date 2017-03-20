extends Node

const PORT = 1111


func _on_HostButton_pressed():
	lobby.host_server(PORT)

func _on_ConnectButton_pressed():
	var ip =  get_node('AdressLineEdit').get_text()
	lobby.connect_to_server(ip, PORT)