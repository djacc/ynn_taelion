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
signal world_changed(old_world: String, new_world: String)

func _ready():
	initialize_area_manager()

func initialize_area_manager():
	if debug_prints:
		print("=== AREA MANAGER INITIALIZATION ===")
	
	# Load the debug world scenes
	debug_world_scene = preload("res://scenes/World/DebugWorld.tscn")
	debug_portal_scene = preload("res://scenes/World/DebugPortal.tscn")
	
	if debug_prints:
		print("Debug world scene loaded: ", debug_world_scene.resource_path)
		print("Debug portal scene loaded: ", debug_portal_scene.resource_path)
		print("Area manager ready!")
		print("================================")
	
	# Initialize the debug world
	initialize_debug_world()

func initialize_debug_world():
	if debug_prints:
		print("=== INITIALIZING DEBUG WORLD ===")
	
	# Create debug world instance
	current_world = debug_world_scene.instantiate()
	add_child(current_world)
	
	# Debug: Check portal configuration
	for child in current_world.get_children():
		if child is Portal:
			if debug_prints:
				print("Portal found in DebugWorld: ", child.name)
				print("  - destination: ", child.get_target_scene_name())
				print("  - can_exit: ", child.can_exit)
				print("  - is_default_spawn: ", child.is_default_spawn)
	
	# Store world data
	worlds_data["DebugWorld"] = {
		"scene": debug_world_scene,
		"node": current_world,
		"loaded": true
	}
	
	if debug_prints:
		print("Debug world loaded as child of AreaManager")
		print("World node: ", current_world.name)
		print("================================")
	
	# Emit signal
	world_loaded.emit("DebugWorld")

func initialize_debug_portal():
	if debug_prints:
		print("=== INITIALIZING DEBUG PORTAL ===")
	
	# Create debug portal instance
	current_world = debug_portal_scene.instantiate()
	add_child(current_world)
	
	# Debug: Check portal configuration
	for child in current_world.get_children():
		if child is Portal:
			if debug_prints:
				print("Portal found in DebugPortal: ", child.name)
				print("  - destination: ", child.get_target_scene_name())
				print("  - can_exit: ", child.can_exit)
				print("  - is_default_spawn: ", child.is_default_spawn)
	
	# Store world data
	worlds_data["DebugPortal"] = {
		"scene": debug_portal_scene,
		"node": current_world,
		"loaded": true
	}
	
	if debug_prints:
		print("Debug portal loaded as child of AreaManager")
		print("World node: ", current_world.name)
		print("================================")
	
	# Emit signal
	world_loaded.emit("DebugPortal")

func get_current_world() -> Node:
	return current_world

func get_current_world_name() -> String:
	if current_world:
		return current_world.name
	return ""

func is_world_loaded(world_name: String) -> bool:
	return worlds_data.has(world_name) and worlds_data[world_name]["loaded"]

func unload_current_world():
	if current_world:
		var world_name = current_world.name
		if debug_prints:
			print("=== UNLOADING WORLD ===")
			print("Unloading: ", world_name)
		

		
		# Remove from scene tree
		current_world.queue_free()
		current_world = null
		
		# Update data
		if worlds_data.has(world_name):
			worlds_data[world_name]["loaded"] = false
			worlds_data[world_name]["node"] = null
		
		if debug_prints:
			print("World unloaded: ", world_name)
			print("================================")
		
		# Emit signal
		world_unloaded.emit(world_name)

func load_world(world_name: String):
	if debug_prints:
		print("=== LOADING WORLD ===")
		print("Loading: ", world_name)
	
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
			if debug_prints:
				print("ERROR: Unknown world: ", world_name)
			return
	
	if debug_prints:
		print("World loaded: ", world_name)
		print("================================")

# Debug function to test world management - REMOVED to avoid conflict with SpawnManager
# func _input(event):
# 	if event.is_action_pressed("reload"):
# 		if debug_prints:
# 			print("=== RELOADING DEBUG WORLD ===")
# 		load_world("DebugWorld") 
