extends Node

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Bhirangatang", favorite_color = Color8(255, 0, 0) }

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(player_name):
	my_info.name = player_name
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)
	print("connected ", id)
	print("info ", player_info)

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.
	print("disconnected ", id)

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info
	print("register ", id, info)
