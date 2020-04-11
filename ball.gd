extends RigidBody2D

const IMPULSE = 160.0

var waypoint = Vector2()
var player_name = "None"
var current_player = false


# Called when the node enters the scene tree for the first time.
func _ready():
	waypoint = get_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dp = waypoint - get_position()
	if dp.length() < 5:
		return
	apply_impulse(Vector2(0,0), dp.normalized() * IMPULSE)
	
func _input(event):
	if current_player and (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		waypoint = get_global_mouse_position()

func set_current():
	current_player = true
	get_node("cam").current = true
	
func set_name(new_name):
	player_name = new_name
	get_node("label").text = new_name
