class_name VNManager
extends Node

@export var debug_prints: bool = true

# Manager properties
var is_active: bool = false
var current_ui_elements: Array[VNBaseUI] = []
var vn_base_ui: VNBaseUI = null

func _ready():
	if debug_prints:
		print("DEBUG: VNManager initialized")
	
	# Start inactive by default
	is_active = false
	
	# Create and add VNBaseUI scene
	create_vn_base_ui()
	
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

func create_vn_base_ui():
	"""Create and add VNBaseUI scene to the manager"""
	if debug_prints:
		print("DEBUG: Creating VNBaseUI scene...")
	
	# Load the VNBaseUI scene
	var vn_base_ui_scene = load("res://scenes/VN/VNBaseUI.tscn")
	if vn_base_ui_scene:
		# Instantiate the scene
		vn_base_ui = vn_base_ui_scene.instantiate()
		
		# Add it as a child of the VNManager
		add_child(vn_base_ui)
		
		# Add to current UI elements array
		current_ui_elements.append(vn_base_ui)
		
		if debug_prints:
			print("DEBUG: VNBaseUI created and added successfully: ", vn_base_ui.name)
			print("DEBUG: VNBaseUI is visible: ", vn_base_ui.is_ui_visible())
	else:
		if debug_prints:
			print("ERROR: Failed to load VNBaseUI scene")

func test_basic_functions():
	"""Test basic manager functionality"""
	if debug_prints:
		print("DEBUG: Testing VNManager functions")
		print("DEBUG: - Initial is_active: ", is_active)
		print("DEBUG: - Current UI elements count: ", current_ui_elements.size())
		print("DEBUG: VNManager ready for testing!")
		
	# Test VNBaseUI if it exists
	if vn_base_ui:
		if debug_prints:
			print("DEBUG: Testing VNBaseUI functionality...")
		vn_base_ui.test_basic_functions()
		
		# Test showing/hiding the UI
		if debug_prints:
			print("DEBUG: Testing UI visibility toggle...")
		vn_base_ui.show_ui()
		vn_base_ui.hide_ui()

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
