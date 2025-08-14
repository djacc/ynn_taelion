extends Node2D

# Debug settings
@export var debug_prints: bool = true

# Export variable for raycast length
@export var raycast_length: float = 64.0

# Movement input system
var movement_stack: Array[String] = []

# Raycast references
var raycast_n: RayCast2D
var raycast_ne: RayCast2D
var raycast_e: RayCast2D
var raycast_se: RayCast2D
var raycast_s: RayCast2D
var raycast_sw: RayCast2D
var raycast_w: RayCast2D
var raycast_nw: RayCast2D

func _ready():
	setup_raycasts()

func setup_raycasts():
	# Get references to all raycasts
	raycast_n = $RayCast2D_N
	raycast_ne = $RayCast2D_NE
	raycast_e = $RayCast2D_E
	raycast_se = $RayCast2D_SE
	raycast_s = $RayCast2D_S
	raycast_sw = $RayCast2D_SW
	raycast_w = $RayCast2D_W
	raycast_nw = $RayCast2D_NW
	
	# Set raycast target positions using the export variable
	raycast_n.target_position = Vector2(0, -raycast_length)
	raycast_ne.target_position = Vector2(raycast_length, -raycast_length)
	raycast_e.target_position = Vector2(raycast_length, 0)
	raycast_se.target_position = Vector2(raycast_length, raycast_length)
	raycast_s.target_position = Vector2(0, raycast_length)
	raycast_sw.target_position = Vector2(-raycast_length, raycast_length)
	raycast_w.target_position = Vector2(-raycast_length, 0)
	raycast_nw.target_position = Vector2(-raycast_length, -raycast_length)
	
	# Initially disable all raycasts
	disable_all_raycasts()

func disable_all_raycasts():
	raycast_n.enabled = false
	raycast_ne.enabled = false
	raycast_e.enabled = false
	raycast_se.enabled = false
	raycast_s.enabled = false
	raycast_sw.enabled = false
	raycast_w.enabled = false
	raycast_nw.enabled = false

func enable_raycast_for_direction(direction: String):
	disable_all_raycasts()  # First disable all
	
	var raycast_end_point: Vector2 = Vector2.ZERO
	
	match direction:
		"N":
			raycast_n.enabled = true
			raycast_end_point = raycast_n.target_position
		"NE":
			raycast_ne.enabled = true
			raycast_end_point = raycast_ne.target_position
		"E":
			raycast_e.enabled = true
			raycast_end_point = raycast_e.target_position
		"SE":
			raycast_se.enabled = true
			raycast_end_point = raycast_se.target_position
		"S":
			raycast_s.enabled = true
			raycast_end_point = raycast_s.target_position
		"SW":
			raycast_sw.enabled = true
			raycast_end_point = raycast_sw.target_position
		"W":
			raycast_w.enabled = true
			raycast_end_point = raycast_w.target_position
		"NW":
			raycast_nw.enabled = true
			raycast_end_point = raycast_nw.target_position
		"IDLE":
			# All raycasts already disabled
			raycast_end_point = Vector2.ZERO
	
	# Return the raycast end point relative to the player position
	return raycast_end_point

func get_current_raycast_end_point() -> Vector2:
	# Get the end point of the currently active raycast
	if raycast_n.enabled:
		return raycast_n.target_position
	elif raycast_ne.enabled:
		return raycast_ne.target_position
	elif raycast_e.enabled:
		return raycast_e.target_position
	elif raycast_se.enabled:
		return raycast_se.target_position
	elif raycast_s.enabled:
		return raycast_s.target_position
	elif raycast_sw.enabled:
		return raycast_sw.target_position
	elif raycast_w.enabled:
		return raycast_w.target_position
	elif raycast_nw.enabled:
		return raycast_nw.target_position
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
			# Two directions - check for cancellation only (no diagonals)
			var dir1 = movement_stack[0]  # older
			var dir2 = movement_stack[1]  # newer
			
			if cancels_out(dir1, dir2):
				# Use the newer direction (last in stack)
				direction = get_cardinal_direction(dir2)
			else:
				# Use the newer direction (last in stack)
				direction = get_cardinal_direction(dir2)
		3:
			# Three directions - cancel out 2, use the 3rd
			var processed_stack = process_three_directions()
			if processed_stack.size() == 1:
				direction = get_cardinal_direction(processed_stack[0])
			else:
				direction = "IDLE"
		4, 5, 6, 7, 8:  # 4 or more directions
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

func forms_diagonal(dir1: String, dir2: String) -> bool:
	# Check if two directions form a diagonal
	return (dir1 == "up" and dir2 == "right") or (dir1 == "right" and dir2 == "up") or \
		   (dir1 == "up" and dir2 == "left") or (dir1 == "left" and dir2 == "up") or \
		   (dir1 == "down" and dir2 == "right") or (dir1 == "right" and dir2 == "down") or \
		   (dir1 == "down" and dir2 == "left") or (dir1 == "left" and dir2 == "down")

func get_diagonal_direction(dir1: String, dir2: String) -> String:
	# Return the diagonal direction based on the two cardinal directions
	if (dir1 == "up" and dir2 == "right") or (dir1 == "right" and dir2 == "up"):
		return "NE"
	elif (dir1 == "up" and dir2 == "left") or (dir1 == "left" and dir2 == "up"):
		return "NW"
	elif (dir1 == "down" and dir2 == "right") or (dir1 == "right" and dir2 == "down"):
		return "SE"
	elif (dir1 == "down" and dir2 == "left") or (dir1 == "left" and dir2 == "down"):
		return "SW"
	else:
		return "IDLE"

func cancels_out(dir1: String, dir2: String) -> bool:
	# Check if two directions cancel each other out
	return (dir1 == "up" and dir2 == "down") or (dir1 == "down" and dir2 == "up") or \
		   (dir1 == "left" and dir2 == "right") or (dir1 == "right" and dir2 == "left")

func process_three_directions() -> Array[String]:
	# Process three directions by canceling out pairs
	var temp_stack = movement_stack.duplicate()
	
	# Check for cancellation pairs
	var i = 0
	while i < temp_stack.size():
		var j = i + 1
		while j < temp_stack.size():
			if cancels_out(temp_stack[i], temp_stack[j]):
				# Remove both directions
				temp_stack.remove_at(j)
				temp_stack.remove_at(i)
				i = -1  # Restart the loop
				break
			j += 1
		i += 1
	
	return temp_stack 
