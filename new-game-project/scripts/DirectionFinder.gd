extends Node2D

# Debug settings
@export var debug_prints: bool = true

# Export variable for raycast length
@export var raycast_length: float = 64.0

# Movement input system
var movement_stack: Array[String] = []

# Raycast references (4-directional only)
var raycast_n: RayCast2D
var raycast_e: RayCast2D
var raycast_s: RayCast2D
var raycast_w: RayCast2D

func _ready():
	setup_raycasts()

func setup_raycasts():
	# Get references to cardinal direction raycasts only
	raycast_n = $RayCast2D_N
	raycast_e = $RayCast2D_E
	raycast_s = $RayCast2D_S
	raycast_w = $RayCast2D_W
	
	# Set raycast target positions using the export variable
	raycast_n.target_position = Vector2(0, -raycast_length)
	raycast_e.target_position = Vector2(raycast_length, 0)
	raycast_s.target_position = Vector2(0, raycast_length)
	raycast_w.target_position = Vector2(-raycast_length, 0)
	
	# Initially disable all raycasts
	disable_all_raycasts()

func disable_all_raycasts():
	raycast_n.enabled = false
	raycast_e.enabled = false
	raycast_s.enabled = false
	raycast_w.enabled = false

func enable_raycast_for_direction(direction: String):
	disable_all_raycasts()  # First disable all
	
	var raycast_end_point: Vector2 = Vector2.ZERO
	
	match direction:
		"N":
			raycast_n.enabled = true
			raycast_end_point = raycast_n.target_position
		"E":
			raycast_e.enabled = true
			raycast_end_point = raycast_e.target_position
		"S":
			raycast_s.enabled = true
			raycast_end_point = raycast_s.target_position
		"W":
			raycast_w.enabled = true
			raycast_end_point = raycast_w.target_position
		"IDLE":
			# All raycasts already disabled
			raycast_end_point = Vector2.ZERO
	
	# Return the raycast end point relative to the player position
	return raycast_end_point

func get_current_raycast_end_point() -> Vector2:
	# Get the end point of the currently active raycast
	if raycast_n.enabled:
		return raycast_n.target_position
	elif raycast_e.enabled:
		return raycast_e.target_position
	elif raycast_s.enabled:
		return raycast_s.target_position
	elif raycast_w.enabled:
		return raycast_w.target_position
	else:
		return Vector2.ZERO

func update_input_state(current_inputs: Array[String]):
	# Update the movement stack with current input state
	movement_stack = current_inputs.duplicate()
	update_movement_direction()
	if debug_prints:
		print("DEBUG: DirectionFinder - Stack: ", movement_stack)

# Keep old functions for compatibility (but they won't be used)
func add_input_action(action: String):
	if action not in movement_stack:
		movement_stack.append(action)
		update_movement_direction()
		if debug_prints:
			print("DEBUG: DirectionFinder - Stack: ", movement_stack)

func remove_input_action(action: String):
	if action in movement_stack:
		movement_stack.erase(action)
		update_movement_direction()
		if debug_prints:
			print("DEBUG: DirectionFinder - Stack: ", movement_stack)

func update_movement_direction():
	var direction = "IDLE"
	var stack_size = movement_stack.size()
	
	match stack_size:
		0:
			direction = "IDLE"
		1:
			# Single direction - use as-is
			direction = get_cardinal_direction(movement_stack[0])
		2:
			# Two directions - check for cancellation only
			var dir1 = movement_stack[0]  # older
			var dir2 = movement_stack[1]  # newer
			
			if cancels_out(dir1, dir2):
				# Use the newer direction (last in stack)
				direction = get_cardinal_direction(dir2)
			else:
				# Use the newer direction (last in stack)
				direction = get_cardinal_direction(dir2)
		3, 4, 5, 6, 7, 8:  # 3 or more directions
			direction = "IDLE"
	
	enable_raycast_for_direction(direction)

func get_cardinal_direction(key_name: String) -> String:
	match key_name:
		"up":
			return "N"
		"down":
			return "S"
		"left":
			return "W"
		"right":
			return "E"
		_:
			return "IDLE"

func cancels_out(dir1: String, dir2: String) -> bool:
	# Check if two directions cancel each other out
	return (dir1 == "up" and dir2 == "down") or (dir1 == "down" and dir2 == "up") or \
		   (dir1 == "left" and dir2 == "right") or (dir1 == "right" and dir2 == "left") 
