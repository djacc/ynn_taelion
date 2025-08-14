extends CharacterBody2D

# Debug settings
@export var debug_prints: bool = true
@export var raycast_debug_prints: bool = true

# Export variable for movement speed
@export var movement_speed: float = 128.0  # pixels per second

# Reference to DirectionFinder
var direction_finder: Node

# Reference to NodeToGrid
var node_to_grid: Node2D

# Movement variables
var is_moving: bool = false
var has_moved: bool = false  # Track if player has moved since spawning

var target_position: Vector2
var movement_timer: Timer

# Export variable for tile delay
@export var tile_delay: float = 0.1  # 100ms delay between tiles

# Input tracking for most recent key
var most_recent_input: String = ""
var input_press_order: Array[String] = []
var blocked_input: String = ""  # Track which input was blocked

# Facing direction
var facing_direction: Vector2 = Vector2.DOWN

# Interaction detection
var current_interactable: Interactable = null
var interaction_raycast: RayCast2D

func _ready():
	# if debug_prints:
	# 	print("=== PLAYER INITIALIZATION ===")
	setup_node_to_grid()
	setup_direction_finder()
	setup_movement_timer()
	setup_interaction_raycast()
	# Initialize has_moved to false
	has_moved = false
	if debug_prints:
		print("DEBUG: has_moved set to false on ready")
		print("Player initialization completed successfully!")
	# 	print("Initial position: ", global_position)
	# 	print("Initial tile: ", node_to_grid.get_current_tile())
	# 	print("=============================")

func setup_node_to_grid():
	# Get reference to the NodeToGrid child node
	node_to_grid = $NodeToGrid
	
	# Snap player to grid
	var snapped_position = node_to_grid.snap_parent_to_nearest_tile()
	# if debug_prints:
	# 	print("Player snapped to grid at: ", snapped_position)

func setup_direction_finder():
	direction_finder = $DirectionFinder

func setup_movement_timer():
	movement_timer = Timer.new()
	movement_timer.wait_time = tile_delay
	movement_timer.one_shot = true
	movement_timer.timeout.connect(_on_movement_timer_timeout)
	add_child(movement_timer)

func setup_interaction_raycast():
	interaction_raycast = $InteractionRaycast

func update_facing_direction():
	# Update facing direction based on most recent input
	match most_recent_input:
		"up":
			facing_direction = Vector2.UP
		"down":
			facing_direction = Vector2.DOWN
		"left":
			facing_direction = Vector2.LEFT
		"right":
			facing_direction = Vector2.RIGHT
		_:
			# Keep current facing direction if no input
			pass
	
	if debug_prints and most_recent_input != "":
		print("Facing direction: ", get_facing_direction_name())

func get_facing_direction() -> Vector2:
	return facing_direction

func get_facing_direction_name() -> String:
	match facing_direction:
		Vector2.UP:
			return "NORTH"
		Vector2.DOWN:
			return "SOUTH"
		Vector2.LEFT:
			return "WEST"
		Vector2.RIGHT:
			return "EAST"
		_:
			return "UNKNOWN"

func set_facing_direction(new_direction: Vector2):
	facing_direction = new_direction
	update_raycast_direction()
	if debug_prints:
		print("Player facing direction set to: ", get_facing_direction_name())



func update_raycast_direction():
	# Update raycast direction based on facing direction
	interaction_raycast.target_position = facing_direction * 128  # 2 tiles
	
	if raycast_debug_prints and most_recent_input != "":
		print("Raycast direction updated to: ", facing_direction)

func check_interaction_in_front() -> Interactable:
	# Force raycast update
	interaction_raycast.force_raycast_update()
	
	if interaction_raycast.is_colliding() and interaction_raycast.get_collider() is Interactable:
		return interaction_raycast.get_collider()
	return null

func is_movement_blocked() -> bool:
	# Use existing interaction_raycast to check for collision
	interaction_raycast.force_raycast_update()
	
	if interaction_raycast.is_colliding():
		var collider = interaction_raycast.get_collider()
		if collider is Interactable and collider.has_collision:
			if raycast_debug_prints:
				print("Collision detected with: ", collider.name)
			return true
	return false



func _on_movement_timer_timeout():
	# Timer finished, allow new movement
	if debug_prints:
		print("Movement timer finished - ready for next input")

func _physics_process(delta):
	# Check if we've entered a new tile
	check_tile_change()
	

	
	# Move toward target if we have one
	if is_moving:
		move_toward_target(delta)
	else:
		# Only handle input when not moving and timer is not running
		if not movement_timer.time_left > 0:
			handle_movement_input()
		elif debug_prints:
			print("Input ignored - timer running: ", movement_timer.time_left)
	


func _input(event):
	# Handle movement input immediately
	if event.is_action_pressed("up") or event.is_action_pressed("down") or event.is_action_pressed("left") or event.is_action_pressed("right"):
		has_moved = true
		if debug_prints:
			print("DEBUG: Movement key pressed - has_moved set to true")
			print("DEBUG: has_moved value = ", has_moved)
	
	# Handle interaction input
	if event.is_action_pressed("interact"):
		if debug_prints:
			print("DEBUG: Interact key pressed (E/Enter)")
		
		# Check what's in front of the player using raycast
		var interactable = check_interaction_in_front()
		if interactable:
			if debug_prints:
				print("DEBUG: Found interactable via raycast: ", interactable.name)
			interactable.start_interaction()
		else:
			if debug_prints:
				print("DEBUG: No interactable found in front of player")

func handle_movement_input():
	# Check all movement actions every frame
	var current_inputs: Array[String] = []
	var new_inputs: Array[String] = []
	
	# Check which inputs are currently pressed
	if Input.is_action_pressed("up"):
		current_inputs.append("up")
		if "up" not in input_press_order:
			new_inputs.append("up")
			input_press_order.append("up")
	if Input.is_action_pressed("down"):
		current_inputs.append("down")
		if "down" not in input_press_order:
			new_inputs.append("down")
			input_press_order.append("down")
	if Input.is_action_pressed("left"):
		current_inputs.append("left")
		if "left" not in input_press_order:
			new_inputs.append("left")
			input_press_order.append("left")
	if Input.is_action_pressed("right"):
		current_inputs.append("right")
		if "right" not in input_press_order:
			new_inputs.append("right")
			input_press_order.append("right")
	

	
	# Remove released inputs from order
	var inputs_to_remove: Array[String] = []
	for input in input_press_order:
		if input not in current_inputs:
			inputs_to_remove.append(input)
	
	for input in inputs_to_remove:
		input_press_order.erase(input)
	
	# Get the most recent input (last in the order)
	if input_press_order.size() > 0:
		most_recent_input = input_press_order[-1]
	else:
		most_recent_input = ""
	
	# Debug: Show current state
	if debug_prints and current_inputs.size() > 0:
		print("Current inputs: ", current_inputs)
		print("Input order: ", input_press_order)
		print("Most recent: ", most_recent_input)
	
	# Update facing direction based on most recent input
	update_facing_direction()
	
	# Update raycast direction to match facing direction
	update_raycast_direction()
	
	# Only check collision if we have new inputs (not just holding existing keys)
	if new_inputs.size() > 0:
		if debug_prints:
			print("DEBUG: Processing new inputs: ", new_inputs)
		

		
		# Check if movement is blocked by collision
		if not is_movement_blocked():
			# Movement is not blocked, proceed with movement
			blocked_input = ""  # Clear blocked input since we can move
			var single_input: Array[String] = []
			if most_recent_input != "":
				single_input.append(most_recent_input)
			
			if debug_prints:
				print("DEBUG: Updating direction finder with: ", single_input)
			direction_finder.update_input_state(single_input)
			
			# Check for new target when input changes
			check_current_target_tile("input_press")
		else:
			# Movement is blocked, stay in place but remain facing that direction
			blocked_input = most_recent_input  # Remember which input was blocked
			if debug_prints:
				print("Movement blocked by collision")
			# DO NOT call direction_finder.update_input_state() or check_current_target_tile()
			# This prevents any movement from starting
	else:
		# No new inputs, check if current input was previously blocked
		if blocked_input == "" or most_recent_input != blocked_input:
			# Input is not blocked, continue with movement
			var single_input: Array[String] = []
			if most_recent_input != "":
				single_input.append(most_recent_input)
			
			direction_finder.update_input_state(single_input)
			
			# Check for new target when input changes
			check_current_target_tile("input_press")
		else:
			# Current input was blocked, don't start movement
			if debug_prints:
				print("Input still blocked: ", blocked_input)

func get_input_action(keycode: int) -> String:
	match keycode:
		KEY_W, KEY_UP:
			return "up"
		KEY_S, KEY_DOWN:
			return "down"
		KEY_A, KEY_LEFT:
			return "left"
		KEY_D, KEY_RIGHT:
			return "right"
		_:
			return ""

func check_tile_change():
	# Check if we've moved to a new tile using NodeToGrid
	if node_to_grid.check_tile_change():
		# if debug_prints:
		# 	print("Entered new tile: ", node_to_grid.get_current_tile())
		# Check for new target when entering new tile
		check_current_target_tile("tile_change")

func check_current_target_tile(caller: String = "unknown"):
	# Only update target if we're not currently moving
	if is_moving:
		if debug_prints:
			print("DEBUG: check_current_target_tile - already moving, returning")
		return
	
	# Get the current raycast end point from DirectionFinder
	var raycast_end_point = direction_finder.get_current_raycast_end_point()
	

	
	# If there's an active raycast (not IDLE)
	if raycast_end_point != Vector2.ZERO:
		# Calculate the absolute world position of the target tile
		var target_world_position = global_position + raycast_end_point
		
		# Convert to tile coordinates using NodeToGrid
		var target_tile = node_to_grid.get_tile_coordinates(target_world_position)
		
		# Convert back to world position to get the exact center of the target tile
		var target_tile_center = node_to_grid.get_tile_center(target_tile)
		
		if debug_prints:
			print("DEBUG: Setting target position to: ", target_tile_center)
		
		# Set new target position for movement
		set_target_position(target_tile_center)
	elif raycast_end_point == Vector2.ZERO and not is_moving:
		# No active raycast and not moving - we're idle
		pass
	# If we're moving but no active raycast, continue to current target

func set_target_position(new_target: Vector2):
	# if debug_prints:
	# 	print("DEBUG: set_target_position called | old_target: ", target_position, " | new_target: ", new_target, " | is_moving: ", is_moving)
	target_position = new_target
	is_moving = true
	if debug_prints:
		print("Movement STARTED to: ", target_position)
	# if debug_prints:
	# 	print("DEBUG: Movement started | target_position: ", target_position, " | is_moving: ", is_moving)

func move_toward_target(delta):
	# Calculate movement vector toward target
	var direction = (target_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target_position)
	
	# Move toward target at constant speed
	var movement = direction * movement_speed * delta
	
	# If we're close enough to target, snap to it exactly
	if distance_to_target <= movement.length():
		global_position = target_position
		is_moving = false
		if debug_prints:
			print("Movement COMPLETED at: ", global_position)
		
		# Check for collision before starting next movement
		if is_movement_blocked():
			if debug_prints:
				print("Movement blocked after completing tile")
			blocked_input = most_recent_input
		else:
			# Start timer for next movement
			movement_timer.start()
		# if debug_prints:
		# 	print("DEBUG: Reached target position | global_position: ", global_position)
	else:
		# Move toward target
		global_position += movement
		# if debug_prints:
		# 	print("DEBUG: Moving toward target | distance: ", distance_to_target, " | movement: ", movement.length())
