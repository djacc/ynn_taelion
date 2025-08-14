class_name AudioManager
extends Node

# Debug settings
@export var debug_prints: bool = false

# Master volume controls
@export var master_volume: float = 1.0
@export var bgm_volume: float = 0.8
@export var sfx_volume: float = 1.0

# Current audio state
var current_world_audio: WorldAudio = null
var is_audio_enabled: bool = true

# Audio state signals
signal world_audio_changed(world_audio: WorldAudio)
signal master_volume_changed(volume: float)
signal bgm_volume_changed(volume: float)
signal sfx_volume_changed(volume: float)

func _ready():
	if debug_prints:
		print("DEBUG: AudioManager initialized")
	
	# Set initial volumes
	update_master_volume(master_volume)
	update_bgm_volume(bgm_volume)
	update_sfx_volume(sfx_volume)

func register_world_audio(world_audio: WorldAudio):
	"""Register a world's audio system with the global manager"""
	if debug_prints:
		print("DEBUG: Registering world audio: ", world_audio.name)
	
	current_world_audio = world_audio
	world_audio_changed.emit(world_audio)

func unregister_world_audio():
	"""Unregister the current world's audio system"""
	if debug_prints:
		print("DEBUG: Unregistering world audio")
	
	current_world_audio = null
	world_audio_changed.emit(null)

func play_bgm(stream: AudioStream, fade_in: bool = true):
	"""Play background music through the current world's audio system"""
	if current_world_audio == null:
		if debug_prints:
			print("WARNING: No world audio registered, cannot play BGM")
		return
	
	if debug_prints:
		print("DEBUG: Playing BGM: ", stream.resource_path if stream else "null")
	
	current_world_audio.play_bgm(stream, fade_in)

func play_sfx(stream: AudioStream):
	"""Play sound effect through the current world's audio system"""
	if current_world_audio == null:
		if debug_prints:
			print("WARNING: No world audio registered, cannot play SFX")
		return
	
	if debug_prints:
		print("DEBUG: Playing SFX: ", stream.resource_path if stream else "null")
	
	current_world_audio.play_sfx(stream)

func stop_bgm(fade_out: bool = true):
	"""Stop background music"""
	if current_world_audio == null:
		return
	
	if debug_prints:
		print("DEBUG: Stopping BGM")
	
	current_world_audio.stop_bgm(fade_out)

func update_master_volume(volume: float):
	"""Update master volume and notify all audio systems"""
	master_volume = clamp(volume, 0.0, 1.0)
	
	if debug_prints:
		print("DEBUG: Master volume set to: ", master_volume)
	
	master_volume_changed.emit(master_volume)

func update_bgm_volume(volume: float):
	"""Update BGM volume and notify all audio systems"""
	bgm_volume = clamp(volume, 0.0, 1.0)
	
	if debug_prints:
		print("DEBUG: BGM volume set to: ", bgm_volume)
	
	bgm_volume_changed.emit(bgm_volume)

func update_sfx_volume(volume: float):
	"""Update SFX volume and notify all audio systems"""
	sfx_volume = clamp(volume, 0.0, 1.0)
	
	if debug_prints:
		print("DEBUG: SFX volume set to: ", sfx_volume)
	
	sfx_volume_changed.emit(sfx_volume)

func get_master_volume() -> float:
	return master_volume

func get_bgm_volume() -> float:
	return bgm_volume

func get_sfx_volume() -> float:
	return sfx_volume

func toggle_audio():
	"""Toggle audio on/off"""
	is_audio_enabled = !is_audio_enabled
	
	if debug_prints:
		print("DEBUG: Audio enabled: ", is_audio_enabled)
	
	# Update all audio systems
	if current_world_audio:
		current_world_audio.set_audio_enabled(is_audio_enabled) 
