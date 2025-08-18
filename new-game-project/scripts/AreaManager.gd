extends Node
class_name AreaManager

# Debug settings
@export var debug_prints: bool = true

# World management
var current_world: Node = null
var worlds_data: Dictionary = {}
var debug_world_scene: PackedScene
var debug_portal_scene: PackedScene

# Signals
signal world_loaded(world_name: String)
signal world_unloaded(world_name: String)

func _ready():
	initialize_area_manager()

func initialize_area_manager():
	# Load the debug world scenes
	debug_world_scene = preload("res://scenes/World/DebugWorld.tscn")
	debug_portal_scene = preload("res://scenes/World/DebugPortal.tscn")
	
	# Check if scenes loaded successfully
	if not debug_world_scene:
		print("ERROR: Failed to load DebugWorld scene")
		return
	if not debug_portal_scene:
		print("ERROR: Failed to load DebugPortal scene")
		return
	
	# Initialize the debug world
	initialize_debug_world()

func initialize_debug_world():
	# Create debug world instance
	current_world = debug_world_scene.instantiate()
	if not current_world:
		print("ERROR: Failed to instantiate DebugWorld")
		return
	
	add_child(current_world)
	
	# Store world data
	worlds_data["DebugWorld"] = {
		"scene": debug_world_scene,
		"node": current_world,
		"loaded": true
	}
	
	# Emit signal
	world_loaded.emit("DebugWorld")

func initialize_debug_portal():
	# Create debug portal instance
	current_world = debug_portal_scene.instantiate()
	if not current_world:
		print("ERROR: Failed to instantiate DebugPortal")
		return
	
	add_child(current_world)
	
	# Store world data
	worlds_data["DebugPortal"] = {
		"scene": debug_portal_scene,
		"node": current_world,
		"loaded": true
	}
	
	# Emit signal
	world_loaded.emit("DebugPortal")

func get_current_world() -> Node:
	return current_world

func get_current_world_name() -> String:
	if current_world:
		return current_world.name
	return ""

func is_world_loaded(world_name: String) -> bool:
	if world_name.is_empty():
		print("WARNING: is_world_loaded called with empty world name")
		return false
	return worlds_data.has(world_name) and worlds_data[world_name]["loaded"]

func unload_current_world():
	if not current_world:
		print("WARNING: unload_current_world called but no world is loaded")
		return
	
	var world_name = current_world.name
	
	# Remove from scene tree
	current_world.queue_free()
	current_world = null
	
	# Update data
	if worlds_data.has(world_name):
		worlds_data[world_name]["loaded"] = false
		worlds_data[world_name]["node"] = null
	else:
		print("WARNING: World data not found for: ", world_name)
	
	# Emit signal
	world_unloaded.emit(world_name)

func load_world(world_name: String):
	if world_name.is_empty():
		print("ERROR: load_world called with empty world name")
		return
	
	# Unload current world if exists
	if current_world:
		unload_current_world()
	
	# Load new world based on name
	match world_name:
		"DebugWorld":
			initialize_debug_world()
		"DebugPortal":
			initialize_debug_portal()
		_:
			print("ERROR: Unknown world: ", world_name)
			return
	
	# Verify world was loaded successfully
	if not current_world:
		print("ERROR: Failed to load world: ", world_name)
		return
