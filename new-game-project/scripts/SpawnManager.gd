extends Node
class_name SpawnManager

# Spawn settings
@export var default_spawn_reference: String = "default"  # Default portal reference to use

# References
var player: Node2D
var player_scene: PackedScene
var area_manager: AreaManager

# Portal registration system
var registered_portals: Dictionary = {}  # world_name -> Array[Portal]
var default_spawn_portals: Dictionary = {}  # world_name -> Portal

func _ready():
	# Use call_deferred to ensure this runs after all nodes are ready
	call_deferred("setup_spawn_system")

func setup_spawn_system():
	# Load the player scene
	player_scene = preload("res://scenes/Player.tscn")
	if not player_scene:
		print("ERROR: Failed to load Player scene")
		return
	
	# Get reference to AreaManager
	area_manager = get_node("/root/Main/AreaManager")
	if area_manager:
		# Connect to AreaManager signals
		area_manager.world_loaded.connect(_on_world_loaded)
		area_manager.world_unloaded.connect(_on_world_unloaded)
		
		# Connect to portals in current world if it exists
		if area_manager.get_current_world():
			connect_to_world_portals()
	else:
		print("ERROR: Could not find AreaManager!")

# Portal registration system
func register_portal(portal: Portal, world_name: String):
	if not portal:
		print("ERROR: Cannot register null portal")
		return
	
	if world_name.is_empty():
		print("ERROR: Cannot register portal with empty world name")
		return
	
	if not registered_portals.has(world_name):
		registered_portals[world_name] = []
	
	if portal not in registered_portals[world_name]:
		registered_portals[world_name].append(portal)
		
		# Check if this is a default spawn portal
		if portal.is_default_spawn:
			if default_spawn_portals.has(world_name):
				print("WARNING: Multiple default spawns in world '", world_name, "'")
				print("Previous default: ", default_spawn_portals[world_name].name)
				print("New default: ", portal.name)
			else:
				default_spawn_portals[world_name] = portal

func unregister_portal(portal: Portal, world_name: String):
	if not portal or world_name.is_empty():
		return
	
	if registered_portals.has(world_name):
		if portal in registered_portals[world_name]:
			registered_portals[world_name].erase(portal)
	
	# Remove from default spawn if it was the default
	if default_spawn_portals.has(world_name) and default_spawn_portals[world_name] == portal:
		default_spawn_portals.erase(world_name)

func find_default_spawn_portal(world_name: String) -> Portal:
	if default_spawn_portals.has(world_name):
		return default_spawn_portals[world_name]
	return null

func find_portal_by_reference(world_name: String, portal_reference: String) -> Portal:
	if registered_portals.has(world_name):
		for portal in registered_portals[world_name]:
			if portal.get_target_scene_name() == portal_reference:
				return portal
	return null

# Travel logic
func travel_to_portal(from_portal: Portal, to_portal: Portal):
	if not from_portal or not to_portal:
		print("ERROR: Invalid portal references for travel")
		return
	
	if not from_portal.can_travel_from_here():
		print("ERROR: Cannot travel from portal '", from_portal.name, "'")
		return
	
	if not to_portal.can_spawn_here():
		print("ERROR: Cannot spawn at portal '", to_portal.name, "'")
		return
	
	# Get the world of the destination portal
	var to_world = to_portal.get_parent()
	if not to_world:
		print("ERROR: Destination portal has no parent world")
		return
	
	# Load the destination world
	var world_name = to_world.name
	area_manager.load_world(world_name)
	
	# Spawn player at the destination portal
	spawn_player_at_specific_portal(world_name, to_portal.get_target_scene_name())

func travel_to_scene(scene_name: String):
	if scene_name.is_empty():
		print("ERROR: Cannot travel to empty scene name")
		return
	
	# Load the scene using AreaManager
	area_manager.load_world(scene_name)
	
	# Spawn player at default spawn in the new scene
	spawn_player_at_default_portal(scene_name)

func travel_to_default_spawn(world_name: String):
	var default_portal = find_default_spawn_portal(world_name)
	if default_portal:
		# Load the world
		area_manager.load_world(world_name)
		
		# Spawn at default portal
		spawn_player_at_default_portal(world_name)
	else:
		print("ERROR: No default spawn portal found in world '", world_name, "'")

# Enhanced spawning methods
func spawn_player_at_default_portal(world_name: String):
	var default_portal = find_default_spawn_portal(world_name)
	if default_portal:
		spawn_player_at_portal(default_portal)
	else:
		print("ERROR: No default spawn portal found in world '", world_name, "'")

func spawn_player_at_specific_portal(world_name: String, portal_reference: String):
	var portal = find_portal_by_reference(world_name, portal_reference)
	if portal:
		spawn_player_at_portal(portal)
	else:
		print("ERROR: Portal with reference '", portal_reference, "' not found in world '", world_name, "'")

func spawn_player_at_portal(portal: Portal):
	if not portal:
		print("ERROR: Cannot spawn at null portal")
		return
	
	if not portal.can_spawn_here():
		print("ERROR: Cannot spawn at portal '", portal.name, "'")
		return
	
	var spawn_position = portal.get_spawn_position()
	var spawn_direction = portal.get_spawn_direction_vector()
	create_player_at_position(spawn_position, portal, spawn_direction)

# Portal validation (simplified - no linked portal references needed)
func validate_portal_links():
	for world_name in registered_portals:
		for portal in registered_portals[world_name]:
			if portal.can_travel_from_here():
				var destination = portal.get_target_scene_name()
				if destination == "No destination configured":
					print("WARNING: Portal '", portal.name, "' in world '", world_name, "' has no destination configured")

func validate_default_spawns():
	for world_name in default_spawn_portals:
		var default_portal = default_spawn_portals[world_name]
		if not default_portal.can_spawn_here():
			print("WARNING: Default spawn portal '", default_portal.name, "' in world '", world_name, "' cannot spawn players")

func find_portals_in_current_world() -> Array[Portal]:
	var portals: Array[Portal] = []
	var current_world = area_manager.get_current_world() if area_manager else null
	
	if current_world:
		for child in current_world.get_children():
			if child is Portal:
				portals.append(child)
	
	return portals

func connect_to_world_portals():
	var portals = find_portals_in_current_world()
	var world_name = area_manager.get_current_world_name()
	
	# Register portals in the current world
	for portal in portals:
		register_portal(portal, world_name)
		
		# Disconnect first to avoid duplicate connections
		if portal.portal_initialized.is_connected(_on_portal_initialized):
			portal.portal_initialized.disconnect(_on_portal_initialized)
		
		# Connect to portal
		portal.portal_initialized.connect(_on_portal_initialized)
		
		# Check if portal is a default spawn
		if portal.is_default_spawn:
			var spawn_position = portal.get_spawn_position()
			var spawn_direction = portal.get_spawn_direction_vector()
			create_player_at_position(spawn_position, portal, spawn_direction)

func spawn_player_at_reference(spawn_reference: String = "default"):
	var portals = find_portals_in_current_world()
	
	for portal in portals:
		if portal.get_target_scene_name() == spawn_reference:
			var spawn_position = portal.get_spawn_position()
			var spawn_direction = portal.get_spawn_direction_vector()
			create_player_at_position(spawn_position, portal, spawn_direction)
			return
	
	print("ERROR: Could not find portal with target scene: ", spawn_reference)

func create_player_at_position(spawn_position: Vector2, source_portal: Portal, spawn_direction: Vector2 = Vector2.DOWN):
	if not source_portal:
		print("ERROR: Cannot create player with null source portal")
		return
	
	# Create player instance
	player = player_scene.instantiate()
	if not player:
		print("ERROR: Failed to instantiate player")
		return
	
	# Add player to current world instead of main scene
	var current_world = area_manager.get_current_world() if area_manager else null
	if current_world:
		current_world.add_child(player)
	else:
		# Fallback to main scene if no world
		get_parent().add_child(player)
	
	# Set player position to portal spawn position
	player.global_position = spawn_position
	
	# Use call_deferred to ensure the player is properly added to the scene tree
	# before trying to access its node_to_grid and setting direction
	call_deferred("_finish_player_spawn", spawn_direction)

func _on_portal_initialized(portal_node: Portal, spawn_position: Vector2, spawn_direction: Vector2):
	# Only auto-spawn if this is a default spawn portal
	if portal_node.is_default_spawn:
		create_player_at_position(spawn_position, portal_node, spawn_direction)

func _on_world_loaded():
	# Connect to portals in the new world
	connect_to_world_portals()

func _on_world_unloaded(world_name: String):
	# Unregister portals from the unloaded world
	if registered_portals.has(world_name):
		for portal in registered_portals[world_name]:
			unregister_portal(portal, world_name)
		registered_portals.erase(world_name)

# Public function to spawn player manually
func spawn_player():
	spawn_player_at_reference(default_spawn_reference)

func _finish_player_spawn(spawn_direction: Vector2 = Vector2.DOWN):
	# This function is called after the player is properly added to the scene tree
	if player and player.has_node("NodeToGrid"):
		player.node_to_grid.snap_parent_to_nearest_tile()
		
		# Set player facing direction
		if player.has_method("set_facing_direction"):
			player.set_facing_direction(spawn_direction)
	else:
		print("ERROR: Player or NodeToGrid not found during spawn completion!")

# Debug function to test spawning
func _input(event):
	if event.is_action_pressed("reload"):  # Press R to manually spawn
		spawn_player() 
