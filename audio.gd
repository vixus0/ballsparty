extends AudioStreamPlayer2D

var playback: AudioStreamGeneratorPlayback

func _ready():
	playback = get_stream_playback()
	AudioServer.capture_start()

func _process(delta):
	var in_buf = AudioServer.get_capture_buffer()
	var len_bytes = AudioServer.get_capture_size()
	var frames = playback.get_frames_available()

	var buf: PoolVector2Array
	for i in range(0,min(len_bytes, frames)):
		buf.append(Vector2(1.0,1.0) * in_buf[i])
	playback.push_buffer(buf)
