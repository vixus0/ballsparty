extends Node

var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(9999, 3)
	get_tree().set_network_peer(peer)
	
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Bhirangatang", favorite_color = Color8(255, 0, 0) }

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)
	print("connected ", id)
	print("info ", player_info)

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.
	print("disconnected ", id)

func _connected_ok():
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info
	print("register ", id, info)
