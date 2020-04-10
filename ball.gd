extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var waypoint = Vector2()
var player_name = "None"
var current_player = false


# Called when the node enters the scene tree for the first time.
func _ready():
	self.waypoint = self.get_global_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dp = self.get_global_position() - self.waypoint
	if dp.length() > 1:
		self.set_global_position(self.get_global_position() - dp * 5 * delta)	
	
func _input(event):
	if current_player and (event is InputEventMouseButton and event.button_index == BUTTON_LEFT):
		self.waypoint = get_global_mouse_position()

func set_current():
	current_player = true
	get_node("cam").current = true
