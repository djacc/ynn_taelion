class_name VNManager
extends Node

@export var debug_prints: bool = true

# Manager properties
var is_active: bool = false
var current_ui_elements: Array[VNBaseUI] = []

func _ready():
	if debug_prints:
		print("DEBUG: VNManager initialized")
	
	# Start inactive by default
	is_active = false
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

func test_basic_functions():
	"""Test basic manager functionality"""
	if debug_prints:
		print("DEBUG: Testing VNManager functions")
		print("DEBUG: - Initial is_active: ", is_active)
		print("DEBUG: - Current UI elements count: ", current_ui_elements.size())
		print("DEBUG: VNManager ready for testing!")

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
