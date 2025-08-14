class_name VNBaseUI
extends Control

@export var debug_prints: bool = true

# Base properties for all VN UI elements
var is_visible: bool = false
var is_active: bool = false

func _ready():
	if debug_prints:
		print("DEBUG: VNBaseUI initialized: ", name)
		print("DEBUG: VNBaseUI position: ", global_position)
		print("DEBUG: VNBaseUI size: ", size)
		print("DEBUG: VNBaseUI parent: ", get_parent().name if get_parent() else "None")
	
	# Start visible by default for testing
	visible = true
	is_visible = true
	is_active = true

func show_ui():
	"""Show this UI element"""
	if debug_prints:
		print("DEBUG: Showing UI: ", name)
	visible = true
	is_visible = true
	is_active = true

func hide_ui():
	"""Hide this UI element"""
	if debug_prints:
		print("DEBUG: Hiding UI: ", name)
	visible = false
	is_visible = false
	is_active = false

func toggle_ui():
	"""Toggle visibility of this UI element"""
	if is_visible:
		hide_ui()
	else:
		show_ui()

func is_ui_visible() -> bool:
	"""Check if UI is currently visible"""
	return is_visible

func is_ui_active() -> bool:
	"""Check if UI is currently active"""
	return is_active

func test_basic_functions():
	"""Test basic UI functionality"""
	if debug_prints:
		print("DEBUG: Testing VNBaseUI functions for: ", name)
		print("DEBUG: - Initial visible: ", visible)
		print("DEBUG: - Initial is_visible: ", is_visible)
		print("DEBUG: - Initial is_active: ", is_active)
