extends Node2D

const BALL = preload("res://ball.tscn")
const PERIOD = 0.5

var my_ip
var menu
var peer
var server = false
var connected = false
var me
var tick = 0

# Player info, associate ID to data
var player_info = {}
var waypoints = {}
var audios = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	me = BALL.instance()
	me.set_global_position(Vector2(500,250))
	me.set_current()
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
	add_child(me)

func _connected_fail():
	menu.visible = true
	get_tree().paused = true

func _server_disconnected():
	menu.visible = true
	get_tree().paused = true

func _on_btn_connect_pressed():
	var player_name = menu.get_node("edit_name").text
	var server_ip = menu.get_node("edit_ip").text
	var server_port = int(menu.get_node("edit_port").text)
	print("client ", player_name, server_ip, server_port)
	peer.create_client(server_ip, server_port)
	get_tree().set_network_peer(peer)
	me.set_name(player_name)

func _on_btn_host_pressed():
	var player_name = menu.get_node("edit_name").text
	var server_port = int(menu.get_node("edit_port").text)
	var max_players = int(menu.get_node("edit_max").text)
	print("server ", player_name, server_port, max_players)
	peer.create_server(server_port, max_players)
	get_tree().set_network_peer(peer)
	me.set_name(player_name)
	_connected_ok()
	server = true
	
func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", {name = me.player_name, pos = me.get_global_position()})
	print("connected ", id)
	print("info ", player_info)

func _player_disconnected(id):
	remove_child(player_info[id])
	player_info.erase(id) # Erase player from info.
	print("disconnected ", id)
	
func _process(delta):
	tick += delta
	if tick > PERIOD:
		tick = 0
		if server:
			waypoints[1] = me.waypoint
			for id in player_info.keys():
				rpc_id(id, "update_all_wp", waypoints)
				rpc_id(id, "update_all_speech", audios)
		else:
			rpc_id(1, "update_wp", me.waypoint)
			
func _speech(data):
	if not server:
		rpc_id(1, "update_speech", data)

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	var ball = BALL.instance()
	ball.set_name(info.name)
	ball.set_global_position(info.pos)
	ball.name = "player-" + str(id)
	player_info[id] = ball
	add_child(ball)
	print("register ", id, info)
	
remote func update_wp(pos):
	var id = get_tree().get_rpc_sender_id()
	player_info[id].waypoint = pos
	waypoints[id] = pos
	
remote func update_all_wp(wps):
	for id in wps.keys():
		if player_info.has(id):
			player_info[id].waypoint = wps[id]
			
remote func update_speech(data):
	print("Updating speech ", data, data.size())
	var id = get_tree().get_rpc_sender_id()
	player_info[id].get_node("speech").stream.set_data(data)
	player_info[id].get_node("speech").play()
	audios[id] = data
	
remote func update_all_speech(audios):
	for id in audios.keys():
		if player_info.has(id):
			player_info[id].get_node("speech").stream.set_data(audios[id])
			player_info[id].get_node("speech").play()
