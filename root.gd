extends Node2D

var my_ip
var menu
var peer
var connected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	peer = NetworkedMultiplayerENet.new()
	my_ip = IP.get_local_addresses()[0]
	menu = get_node("menu/grid")
	get_node("menu").pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _connected_ok():
	connected = true
	get_node("menu").visible = false
	get_tree().paused = false

func _connected_fail():
	get_node("menu").visible = true
	get_tree().paused = true

func _server_disconnected():
	get_node("menu").visible = true
	get_tree().paused = true

func _on_btn_connect_pressed():
	var name = menu.get_node("edit_name").text
	var server_ip = menu.get_node("edit_ip").text
	var server_port = int(menu.get_node("edit_port").text)
	print("client ", name, server_ip, server_port)
	peer.create_client(server_ip, server_port)
	get_tree().set_network_peer(peer)


func _on_btn_host_pressed():
	var name = menu.get_node("edit_name").text
	var server_port = int(menu.get_node("edit_port").text)
	var max_players = int(menu.get_node("edit_max").text)
	print("server ", name, server_port, max_players)
	peer.create_server(server_port, max_players)
	get_tree().set_network_peer(peer)
	_connected_ok()
