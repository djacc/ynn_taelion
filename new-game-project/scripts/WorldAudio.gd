class_name WorldAudio
extends Control

# Volume controls (exposed for easy adjustment)
@export var bgm_volume: float = 0.8
@export var sfx_volume: float = 1.0

# Audio nodes
var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# Audio state
var is_audio_enabled: bool = true
var current_bgm_stream: AudioStream = null

# Fade settings
@export var fade_duration: float = 1.0
var fade_tween: Tween

# AudioManager reference
var audio_manager: AudioManager

func _ready():
	setup_audio_nodes()
	setup_audio_manager_connection()
	
	# Register with AudioManager
	register_with_audio_manager()

func setup_audio_nodes():
	"""Setup BGM and SFX audio nodes"""
	# Create BGM player
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGM"
	bgm_player.volume_db = linear_to_db(bgm_volume)
	bgm_player.bus = "Master"
	add_child(bgm_player)
	
	# Create SFX player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFX"
	sfx_player.volume_db = linear_to_db(sfx_volume)
	sfx_player.bus = "Master"
	add_child(sfx_player)

func setup_audio_manager_connection():
	"""Connect to AudioManager signals"""
	# Find AudioManager under Main
	audio_manager = get_node("/root/Main/AudioManager")
	if audio_manager == null:
		# Try to find it in the current scene
		audio_manager = get_tree().get_first_node_in_group("audio_manager")
	
	if audio_manager:
		audio_manager.master_volume_changed.connect(_on_master_volume_changed)
		audio_manager.bgm_volume_changed.connect(_on_bgm_volume_changed)
		audio_manager.sfx_volume_changed.connect(_on_sfx_volume_changed)
	else:
		print("WARNING: WorldAudio '", name, "' could not find AudioManager")

func register_with_audio_manager():
	"""Register this world audio with the global AudioManager"""
	if audio_manager:
		audio_manager.register_world_audio(self)
	else:
		print("WARNING: WorldAudio '", name, "' cannot register - AudioManager not found")

func _exit_tree():
	"""Cleanup when the world audio is removed"""
	if audio_manager:
		audio_manager.unregister_world_audio()

func play_bgm(stream: AudioStream, fade_in: bool = true):
	"""Play background music"""
	if not is_audio_enabled:
		return
	
	if stream == null:
		print("WARNING: WorldAudio '", name, "' attempted to play null BGM stream")
		return
	
	current_bgm_stream = stream
	bgm_player.stream = stream
	
	if fade_in:
		# Start with volume 0 and fade in
		bgm_player.volume_db = linear_to_db(0.0)
		bgm_player.play()
		
		fade_tween = create_tween()
		fade_tween.tween_property(bgm_player, "volume_db", 
			linear_to_db(bgm_volume), fade_duration)
	else:
		bgm_player.volume_db = linear_to_db(bgm_volume)
		bgm_player.play()

func play_sfx(stream: AudioStream):
	"""Play sound effect"""
	if not is_audio_enabled:
		return
	
	if stream == null:
		print("WARNING: WorldAudio '", name, "' attempted to play null SFX stream")
		return
	
	sfx_player.stream = stream
	sfx_player.play()

func stop_bgm(fade_out: bool = true):
	"""Stop background music"""
	if fade_out and bgm_player.playing:
		fade_tween = create_tween()
		fade_tween.tween_property(bgm_player, "volume_db", 
			linear_to_db(0.0), fade_duration)
		fade_tween.tween_callback(bgm_player.stop)
	else:
		bgm_player.stop()
	
	current_bgm_stream = null

func set_audio_enabled(enabled: bool):
	"""Enable or disable audio playback"""
	is_audio_enabled = enabled
	
	if not enabled:
		bgm_player.stop()
		sfx_player.stop()

func _on_master_volume_changed(volume: float):
	"""Handle master volume changes from AudioManager"""
	# Note: volume parameter is required by signal signature but not used directly
	# as update_volume_levels() gets current values from AudioManager
	update_volume_levels()

func _on_bgm_volume_changed(volume: float):
	"""Handle BGM volume changes from AudioManager"""
	bgm_volume = volume
	update_volume_levels()

func _on_sfx_volume_changed(volume: float):
	"""Handle SFX volume changes from AudioManager"""
	sfx_volume = volume
	update_volume_levels()

func update_volume_levels():
	"""Update volume levels based on current settings"""
	if not audio_manager:
		return
	
	var master_vol = audio_manager.get_master_volume()
	var bgm_vol = audio_manager.get_bgm_volume()
	var sfx_vol = audio_manager.get_sfx_volume()
	
	bgm_player.volume_db = linear_to_db(bgm_volume * bgm_vol * master_vol)
	sfx_player.volume_db = linear_to_db(sfx_volume * sfx_vol * master_vol)

func get_current_bgm() -> AudioStream:
	"""Get the currently playing BGM stream"""
	return current_bgm_stream

func is_bgm_playing() -> bool:
	"""Check if BGM is currently playing"""
	return bgm_player.playing

func is_sfx_playing() -> bool:
	"""Check if SFX is currently playing"""
	return sfx_player.playing 
