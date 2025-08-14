class_name WorldAudio
extends Control

# Debug settings
@export var debug_prints: bool = false

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
	if debug_prints:
		print("DEBUG: WorldAudio initialized for: ", name)
	
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
	
	if debug_prints:
		print("DEBUG: Audio nodes created - BGM: ", bgm_player.name, ", SFX: ", sfx_player.name)

func setup_audio_manager_connection():
	"""Connect to AudioManager signals"""
	# Find AudioManager in the scene tree
	audio_manager = get_node("/root/AudioManager")
	if audio_manager == null:
		# Try to find it in the current scene
		audio_manager = get_tree().get_first_node_in_group("audio_manager")
	
	if audio_manager:
		audio_manager.master_volume_changed.connect(_on_master_volume_changed)
		audio_manager.bgm_volume_changed.connect(_on_bgm_volume_changed)
		audio_manager.sfx_volume_changed.connect(_on_sfx_volume_changed)
		
		if debug_prints:
			print("DEBUG: Connected to AudioManager signals")
	else:
		if debug_prints:
			print("WARNING: AudioManager not found")

func register_with_audio_manager():
	"""Register this world audio with the global AudioManager"""
	if audio_manager:
		audio_manager.register_world_audio(self)
		if debug_prints:
			print("DEBUG: Registered with AudioManager")

func _exit_tree():
	"""Cleanup when the world audio is removed"""
	if audio_manager:
		audio_manager.unregister_world_audio()
		if debug_prints:
			print("DEBUG: Unregistered from AudioManager")

func play_bgm(stream: AudioStream, fade_in: bool = true):
	"""Play background music"""
	if not is_audio_enabled:
		return
	
	if stream == null:
		if debug_prints:
			print("WARNING: Attempted to play null BGM stream")
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
	
	if debug_prints:
		print("DEBUG: Playing BGM: ", stream.resource_path)

func play_sfx(stream: AudioStream):
	"""Play sound effect"""
	if not is_audio_enabled:
		return
	
	if stream == null:
		if debug_prints:
			print("WARNING: Attempted to play null SFX stream")
		return
	
	sfx_player.stream = stream
	sfx_player.play()
	
	if debug_prints:
		print("DEBUG: Playing SFX: ", stream.resource_path)

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
	
	if debug_prints:
		print("DEBUG: Stopped BGM")

func set_audio_enabled(enabled: bool):
	"""Enable or disable audio playback"""
	is_audio_enabled = enabled
	
	if not enabled:
		bgm_player.stop()
		sfx_player.stop()
	
	if debug_prints:
		print("DEBUG: Audio enabled: ", enabled)

func _on_master_volume_changed(volume: float):
	"""Handle master volume changes from AudioManager"""
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
	if audio_manager:
		var master_vol = audio_manager.get_master_volume()
		var bgm_vol = audio_manager.get_bgm_volume()
		var sfx_vol = audio_manager.get_sfx_volume()
		
		bgm_player.volume_db = linear_to_db(bgm_volume * bgm_vol * master_vol)
		sfx_player.volume_db = linear_to_db(sfx_volume * sfx_vol * master_vol)
		
		if debug_prints:
			print("DEBUG: Updated volume levels - BGM: ", bgm_volume * bgm_vol * master_vol, 
				", SFX: ", sfx_volume * sfx_vol * master_vol)

func get_current_bgm() -> AudioStream:
	"""Get the currently playing BGM stream"""
	return current_bgm_stream

func is_bgm_playing() -> bool:
	"""Check if BGM is currently playing"""
	return bgm_player.playing

func is_sfx_playing() -> bool:
	"""Check if SFX is currently playing"""
	return sfx_player.playing 
