extends Node2D

const BALL = preload("res://ball.tscn")

var my_ip
var menu
var peer
var connected = false
var me

# Player info, associate ID to data
var player_info = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	peer = NetworkedMultiplayerENet.new()
	my_ip = IP.get_local_addresses()[0]
	menu = get_node("static/menu/grid")
	get_node("static/menu/lbl_myip_value").text = my_ip
	menu.pause_mode = Node.PAUSE_MODE_PROCESS
	get_tree().paused = true
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")


func _connected_ok():
	connected = true
	menu.visible = false
	get_tree().paused = false
	_create_player(name)

func _connected_fail():
	menu.visible = true
	get_tree().paused = true

func _server_disconnected():
	menu.visible = true
	get_tree().paused = true
	
func _create_player(host_name):
	me = BALL.instance()
	me.player_name = host_name
	add_child(me)

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
	
func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", {name = me.player_name, pos = me.get_global_position()})
	print("connected ", id)
	print("info ", player_info)

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.
	print("disconnected ", id)

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	var ball = BALL.instance()
	ball.player_name = info.name
	ball.set_global_position(info.pos)
	player_info[id] = ball
	print("register ", id, info)
