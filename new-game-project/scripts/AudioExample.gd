class_name AudioExample
extends Node

# Debug settings
@export var debug_prints: bool = true

# Audio streams (assign these in the editor)
@export var bgm_stream: AudioStream
@export var sfx_stream: AudioStream

# References
var world_audio: WorldAudio
var audio_manager: AudioManager

func _ready():
	if debug_prints:
		print("DEBUG: AudioExample initialized")
	
	setup_audio_references()
	
	# Example: Play BGM on world load
	if bgm_stream:
		play_world_bgm()

func setup_audio_references():
	"""Setup references to audio components"""
	# Find WorldAudio in the scene
	world_audio = get_node("../WorldAudio")
	if world_audio == null:
		world_audio = get_tree().get_first_node_in_group("world_audio")
	
	# Find AudioManager
	audio_manager = get_node("/root/AudioManager")
	if audio_manager == null:
		audio_manager = get_tree().get_first_node_in_group("audio_manager")
	
	if debug_prints:
		if world_audio:
			print("DEBUG: Found WorldAudio: ", world_audio.name)
		else:
			print("WARNING: WorldAudio not found")
		
		if audio_manager:
			print("DEBUG: Found AudioManager: ", audio_manager.name)
		else:
			print("WARNING: AudioManager not found")

func play_world_bgm():
	"""Play the world's background music"""
	if world_audio and bgm_stream:
		world_audio.play_bgm(bgm_stream, true)  # true for fade in
		if debug_prints:
			print("DEBUG: Playing world BGM")

func play_world_sfx():
	"""Play a sound effect"""
	if world_audio and sfx_stream:
		world_audio.play_sfx(sfx_stream)
		if debug_prints:
			print("DEBUG: Playing world SFX")

func stop_world_bgm():
	"""Stop the background music"""
	if world_audio:
		world_audio.stop_bgm(true)  # true for fade out
		if debug_prints:
			print("DEBUG: Stopped world BGM")

# Example input handling for testing
func _input(event):
	if event.is_action_pressed("ui_accept"):
		# Press Enter to play SFX
		play_world_sfx()
	elif event.is_action_pressed("ui_cancel"):
		# Press Escape to stop BGM
		stop_world_bgm()
	elif event.is_action_pressed("ui_select"):
		# Press Space to restart BGM
		play_world_bgm() 