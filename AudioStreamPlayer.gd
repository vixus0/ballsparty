extends AudioStreamPlayer

var playback

var effect
var recording
var tick = 0.0
var PERIOD = 5

func _ready():
	var idx = AudioServer.get_bus_index("Record")
	# And use it to retrieve its first effect, which has been defined
	# as an "AudioEffectRecord" resource.
	effect = AudioServer.get_bus_effect(idx, 0)
	
	effect.set_recording_active(true)

func _process(delta):
	tick += delta
	if tick > PERIOD:
		tick = 0
		
		effect.set_recording_active(false)
		recording = effect.get_recording()
		print('recording', recording)
		print(recording.format)
		print(recording.mix_rate)
		print(recording.stereo)
		var data = recording.get_data()
		print('data', data, data.size())
		self.stream = recording
		recording.save_to_wav('test.wav')
		self.play()
		
		# Sleep for 3 seconds
		var t = Timer.new()
		t.set_wait_time(3)
		add_child(t)
		t.start()
		yield(t, "timeout")	
		
		self.stop()
