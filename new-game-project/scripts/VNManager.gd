class_name VNManager
extends Node

@export var debug_prints: bool = false

# Manager properties
var is_active: bool = false
var current_ui_elements: Array[VNBaseUI] = []

func _ready():
	if debug_prints:
		print("DEBUG: VNManager initialized")
	
	# Start inactive by default
	is_active = false
	
	# Listen for player spawn signal
	connect_to_player_spawn_signal()
	
	# Don't create VNBaseUI yet - wait for player spawn
	if debug_prints:
		print("DEBUG: Waiting for player spawn signal...")
	
	test_basic_functions()

func activate_vn_system():
	"""Activate the VN system"""
	if debug_prints:
		print("DEBUG: Activating VN system")
	is_active = true

func deactivate_vn_system():
	"""Deactivate the VN system"""
	if debug_prints:
		print("DEBUG: Deactivating VN system")
	is_active = false

func is_vn_system_active() -> bool:
	"""Check if VN system is active"""
	return is_active

func connect_to_player_spawn_signal():
	"""Connect to the player spawn signal"""
	if debug_prints:
		print("DEBUG: Attempting to connect to player spawn signal...")
	
	# Try to connect to the signal from the SpawnManager
	var spawn_manager = get_node_or_null("../SpawnManager")
	if spawn_manager and spawn_manager.has_signal("player_spawned"):
		spawn_manager.connect("player_spawned", _on_player_spawned)
		if debug_prints:
			print("DEBUG: Connected to SpawnManager player_spawned signal")
	else:
		if debug_prints:
			print("WARNING: SpawnManager or player_spawned signal not found")
			print("DEBUG: Will try to connect later...")

func _on_player_spawned(player_node: Node):
	"""Called when player is spawned"""
	if debug_prints:
		print("DEBUG: Player spawned signal received: ", player_node.name)
	
	# Now create and attach VNBaseUI to the player's camera
	create_vn_base_ui_for_player(player_node)

func create_vn_base_ui_for_player(player_node: Node):
	"""Create VNBaseUI and attach to the specific player's camera"""
	if debug_prints:
		print("DEBUG: Creating VNBaseUI for player: ", player_node.name)
	
	# Look for Camera2D as a child of the player
	var camera = player_node.get_node_or_null("Camera2D")
	if camera:
		if debug_prints:
			print("DEBUG: Found player camera: ", camera.name)
		
		# Create and attach VNBaseUI to the camera
		create_vn_base_ui_at_camera(camera)
	else:
		if debug_prints:
			print("ERROR: No Camera2D found as child of player")

func create_vn_base_ui_at_camera(camera: Camera2D):
	"""Create VNBaseUI and attach to the specified camera"""
	if debug_prints:
		print("DEBUG: Creating VNBaseUI at camera: ", camera.name)
	
	# Load the VNBaseUI scene
	var vn_base_ui_scene = load("res://scenes/VN/VNBaseUI.tscn")
	if vn_base_ui_scene:
		# Instantiate the scene
		var vn_base_ui = vn_base_ui_scene.instantiate()
		
		# Add VNBaseUI as a child of the camera
		camera.add_child(vn_base_ui)
		if debug_prints:
			print("DEBUG: VNBaseUI attached to camera: ", camera.name)
		
		# Add to current UI elements array
		current_ui_elements.append(vn_base_ui)
		
		if debug_prints:
			print("DEBUG: VNBaseUI created and added successfully: ", vn_base_ui.name)
			print("DEBUG: VNBaseUI is visible: ", vn_base_ui.is_ui_visible())
	else:
		if debug_prints:
			print("ERROR: Failed to load VNBaseUI scene")

func create_vn_base_ui():
	"""Legacy function - now handled by signal-based system"""
	if debug_prints:
		print("DEBUG: create_vn_base_ui() called - this is now handled by signal system")
		print("DEBUG: VNBaseUI will be created when player spawns")

func test_basic_functions():
	"""Test basic manager functionality"""
	if debug_prints:
		print("DEBUG: Testing VNManager functions")
		print("DEBUG: - Initial is_active: ", is_active)
		print("DEBUG: - Current UI elements count: ", current_ui_elements.size())
		print("DEBUG: VNManager ready for testing!")
		
		# Test VNBaseUI if it exists
	if current_ui_elements.size() > 0:
		var vn_base_ui = current_ui_elements[0]
		if debug_prints:
			print("DEBUG: Testing VNBaseUI functionality...")
		vn_base_ui.test_basic_functions()
		
		# Test showing the UI (keep it visible)
		if debug_prints:
			print("DEBUG: Testing UI visibility...")
		vn_base_ui.show_ui()
		# Don't hide it - keep it visible for testing

# Placeholder functions for future UI management
func show_ui_element(ui_element: VNBaseUI):
	"""Show a specific UI element (placeholder)"""
	if debug_prints:
		print("DEBUG: Placeholder: show_ui_element called for: ", ui_element.name if ui_element else "null")

func hide_ui_element(ui_element: VNBaseUI):
	"""Hide a specific UI element (placeholder)"""
	if debug_prints:
		print("DEBUG: Placeholder: hide_ui_element called for: ", ui_element.name if ui_element else "null")

func show_image(image_path: String, position: Vector2):
	"""Show an image at specific position (placeholder)"""
	if debug_prints:
		print("DEBUG: Placeholder: show_image called for: ", image_path, " at position: ", position)

func hide_image(image_path: String):
	"""Hide a specific image (placeholder)"""
	if debug_prints:
		print("DEBUG: Placeholder: hide_image called for: ", image_path)
