extends Node2D
class_name Portal

# Debug settings
@export var debug_prints: bool = true

# Portal configuration
# Manual scene path mapping (no circular references!)
var scene_destinations = {
	"DebugWorld": {
		"PortalA": "DebugPortal",
		"PortalB": "DebugPortal"
	},
	"DebugPortal": {
		"PortalInDebug": "DebugWorld"
	}
}

# Portal behavior
@export var can_exit: bool = false  # Whether this portal can be used to exit/travel
@export var is_default_spawn: bool = false
@export var target_scene_name: String = ""  # Type scene name here: "DebugPortal", "DebugWorld", etc.

# Spawn direction enum for inspector dropdown
enum SpawnDirection { NORTH, SOUTH, EAST, WEST }
@export var spawn_direction: SpawnDirection = SpawnDirection.NORTH  # Direction player should face when spawning

# Portal configuration

# References
var node_to_grid: Node2D
var spawn_manager: SpawnManager
var trigger_area: Area2D
var last_trigger_time: float = 0.0
var trigger_cooldown: float = 1.0  # 1 second cooldown between triggers
var last_exit_body: String = ""
var active_bodies: Array[String] = []  # Track bodies currently in the area

# Signals
signal portal_initialized(portal: Portal, spawn_position: Vector2, spawn_direction: Vector2)

func _ready():
	setup_node_to_grid()
	setup_trigger_area()
	validate_default_spawn()
	initialize_portal()
	setup_spawn_manager_reference()
	
	# Debug target scene assignment
	if debug_prints:
		print("=== PORTAL READY ===")
		print("Portal: ", name)
		print("Can Exit: ", can_exit)
		print("Is Default Spawn: ", is_default_spawn)
		print("Target Scene Name: ", get_target_scene_name())
		print("Position: ", global_position)
		print("================================")

func setup_spawn_manager_reference():
	# Get reference to SpawnManager
	spawn_manager = get_node("/root/Main/SpawnManager")
	if not spawn_manager and debug_prints:
		print("ERROR: Could not find SpawnManager")

func setup_node_to_grid():
	# Get reference to the NodeToGrid child node
	node_to_grid = $NodeToGrid
	
	# Snap portal to grid
	var snapped_position = node_to_grid.snap_parent_to_nearest_tile()
	if debug_prints:
		print("Portal snapped to grid at: ", snapped_position)

func setup_trigger_area():
	# Get reference to the existing Area2D node
	trigger_area = $TriggerArea
	if not trigger_area:
		if debug_prints:
			print("ERROR: Could not find TriggerArea node")
		return
	
	# Connect signals
	trigger_area.body_entered.connect(_on_player_entered_tile)
	trigger_area.body_exited.connect(_on_player_exited_tile)
	
	if debug_prints:
		print("=== PORTAL TRIGGER AREA SETUP ===")
		print("Portal: ", name)
		print("Trigger area found: ", trigger_area.name)
		print("Collision layer: ", trigger_area.collision_layer)
		print("Collision mask: ", trigger_area.collision_mask)
		print("Signals connected")
		print("================================")

func validate_default_spawn():
	# Check if this portal is marked as default spawn
	if is_default_spawn:
		# Find other portals in the same world that might also be default
		var current_world = get_parent()
		if current_world:
			for child in current_world.get_children():
				if child is Portal and child != self and child.is_default_spawn:
					if debug_prints:
						print("WARNING: Multiple default spawns detected in world: ", current_world.name)
						print("Portal '", child.name, "' is also marked as default spawn")
						print("Portal '", name, "' is marked as default spawn")
					# For now, just warn - we'll handle this more robustly later
					break

func initialize_portal():
	# Get the spawn position (center of the tile)
	var spawn_position = node_to_grid.get_current_tile_center()
	var tile_coordinates = node_to_grid.get_current_tile()
	
	# Emit signal with portal info including spawn direction
	portal_initialized.emit(self, spawn_position, get_spawn_direction_vector())
	
	if debug_prints:
		print("=== PORTAL INITIALIZATION ===")
		print("Portal Name: ", name)
		print("Target Scene: ", get_target_scene_name())
		print("Can Exit: ", can_exit)
		print("Is Default Spawn: ", is_default_spawn)
		print("Tile Coordinates: ", tile_coordinates)
		print("Spawn Position: ", spawn_position)
		print("Spawn Direction: ", get_spawn_direction_name())
		print("=============================")

func get_spawn_position() -> Vector2:
	# Return the center position of the current tile
	return node_to_grid.get_current_tile_center()

func get_target_scene_name() -> String:
	# First check if target_scene_name is set in the editor
	if target_scene_name != "":
		return target_scene_name
	
	# Fallback to manual mapping for backward compatibility
	var current_world = get_parent()
	if not current_world:
		return "Unknown World"
	
	var world_name = current_world.name
	var portal_name = name
	
	# Check if this portal has a destination configured in manual mapping
	if world_name in scene_destinations and portal_name in scene_destinations[world_name]:
		return scene_destinations[world_name][portal_name]
	
	return "No destination configured"

func get_spawn_direction_vector() -> Vector2:
	match spawn_direction:
		SpawnDirection.NORTH:
			return Vector2.UP
		SpawnDirection.SOUTH:
			return Vector2.DOWN
		SpawnDirection.EAST:
			return Vector2.RIGHT
		SpawnDirection.WEST:
			return Vector2.LEFT
		_:
			return Vector2.DOWN

func get_spawn_direction_name() -> String:
	match spawn_direction:
		SpawnDirection.NORTH:
			return "NORTH"
		SpawnDirection.SOUTH:
			return "SOUTH"
		SpawnDirection.EAST:
			return "EAST"
		SpawnDirection.WEST:
			return "WEST"
		_:
			return "UNKNOWN"

func is_entrance_portal() -> bool:
	return true  # All portals can be entrances

func is_exit_portal() -> bool:
	return can_exit  # Only if can_exit is true

func can_spawn_here() -> bool:
	return is_entrance_portal()

func can_travel_from_here() -> bool:
	return is_exit_portal() and get_target_scene_name() != "No destination configured"

# Removed linked_portal functionality - using target_scene_name instead

# Tile-based trigger for exit portals
func _on_player_entered_tile(body: Node2D):
	var current_time = Time.get_unix_time_from_system()
	var body_id = str(body.get_instance_id())
	
	# Check if this body is already being tracked
	if body_id in active_bodies:
		return
	
	# Add body to active tracking
	active_bodies.append(body_id)
	
	# Check if this is the player (more robust detection)
	var is_player = false
	if body.name == "Player":
		is_player = true
	elif body.has_method("is_player") and body.is_player():
		is_player = true
	elif body.get_class() == "CharacterBody2D" and body.has_node("NodeToGrid"):
		is_player = true
	
	# Print portal entry for main Player node
	if is_player and body.name == "Player":
		if debug_prints:
			print("Entered portal: ", name)
			print("Exit = ", can_exit)
	
	# Check cooldown to prevent multiple triggers
	if current_time - last_trigger_time < trigger_cooldown:
		if debug_prints:
			print("Trigger blocked by cooldown")
		return
	
	# Check if player has moved since spawning
	var player_has_moved = false
	if is_player and "has_moved" in body:
		player_has_moved = body.has_moved
		if debug_prints:
			print("DEBUG: Player has_moved = ", body.has_moved)
	
	if debug_prints:
		print("Portal conditions check:")
		print("  - is_player: ", is_player)
		print("  - can_exit: ", can_exit)
		print("  - has_destination: ", get_target_scene_name() != "No destination configured")
		print("  - destination: ", get_target_scene_name())
		print("  - player_has_moved: ", player_has_moved)

	
	# Only trigger if conditions are met and player has moved
	if is_player and can_exit and get_target_scene_name() != "No destination configured" and player_has_moved:
		if debug_prints:
			print("=== PORTAL TRIGGERED ===")
			print("Portal: ", name)
			print("Target Scene: ", get_target_scene_name())
			print("Can Exit: ", can_exit)
			print("Traveling to scene...")
		
		# Set trigger time to prevent multiple triggers
		last_trigger_time = current_time
		
		# Trigger travel to the target scene
		trigger_travel_to_scene()
	elif debug_prints:
		print("Portal not triggered - conditions not met")

func _on_player_exited_tile(body: Node2D):
	var current_time = Time.get_unix_time_from_system()
	var body_id = str(body.get_instance_id())
	
	# Check if this body is being tracked
	if body_id not in active_bodies:
		return
	
	# Remove body from active tracking
	active_bodies.erase(body_id)
	
	# Check if this is the player (same logic as above)
	var is_player = false
	if body.name == "Player":
		is_player = true
	elif body.has_method("is_player") and body.is_player():
		is_player = true
	elif body.get_class() == "CharacterBody2D" and body.has_node("NodeToGrid"):
		is_player = true
	
	# Only print exit message for the main Player node
	if is_player and body.name == "Player":
		if debug_prints:
			print("Player exited portal tile: ", name)

func trigger_travel_to_scene():
	var destination = get_target_scene_name()
	if destination == "No destination configured":
		if debug_prints:
			print("ERROR: No destination configured for portal")
		return
	
	if not spawn_manager:
		if debug_prints:
			print("ERROR: SpawnManager not found")
		return
	
	if debug_prints:
		print("Traveling to destination: ", destination)
	
	# Use SpawnManager to travel to the scene
	spawn_manager.travel_to_scene(destination)

func set_target_scene(scene: PackedScene):
	# This function is deprecated - use scene_destinations mapping instead
	pass

func set_spawn_direction(new_direction: SpawnDirection):
	spawn_direction = new_direction

func set_can_exit(can_exit_portal: bool):
	can_exit = can_exit_portal

func set_default_spawn(is_default: bool):
	is_default_spawn = is_default

# Utility function to check if a node is the player
func is_player() -> bool:
	return false  # This is a portal, not a player 
