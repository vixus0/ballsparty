extends RigidBody2D

const IMPULSE = 160.0
const REC_PERIOD = 0.5

var waypoint = Vector2()
var player_name = "None"
var current_player = false
var recording = false
var rec_tick = 0.0
var fx_rec

# Called when the node enters the scene tree for the first time.
func _ready():
	waypoint = get_position()
	var index = AudioServer.get_bus_index("Record")
	fx_rec = AudioServer.get_bus_effect(index, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dp = waypoint - get_position()
	if dp.length() < 5:
		return
	apply_impulse(Vector2(0,0), dp.normalized() * IMPULSE)
	
	if recording:
		if rec_tick > REC_PERIOD:
			rec_tick = 0.0
			var audio_data = fx_rec.get_recording()
			fx_rec.set_recording_active(false)
			fx_rec.set_recording_active(true)
			get_parent()._speech(audio_data)
		rec_tick += delta
	else:
		rec_tick = 0.0
	
func _input(event):
	if current_player and event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			waypoint = get_global_mouse_position()
		elif event.button_index == BUTTON_RIGHT:
			input_record(event)

func set_current():
	current_player = true
	get_node("cam").current = true
	
func set_name(new_name):
	player_name = new_name
	get_node("label").text = new_name
	
func input_record(ev):
	if ev.is_pressed():
		if not recording:
			fx_rec.set_recording_active(true)
			$label.text = "<speak>"
			recording = true
	else:
		fx_rec.set_recording_active(false)
		$label.text = player_name
		recording = false
