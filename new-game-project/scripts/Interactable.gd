class_name Interactable
extends Area2D

# Interaction properties
@export var has_collision: bool = true

# Grid positioning
var node_to_grid: Node2D

# Interaction signal
signal interaction_started()

func _ready():
	# Setup grid positioning
	setup_node_to_grid()

func setup_node_to_grid():
	# Get reference to the NodeToGrid child node
	node_to_grid = get_node_or_null("NodeToGrid")
	
	if not node_to_grid:
		print("ERROR: Interactable '", name, "' missing NodeToGrid child node")
		return
	
	# Snap interactable to grid
	var snapped_position = node_to_grid.snap_parent_to_nearest_tile()
	if not snapped_position:
		print("WARNING: Failed to snap Interactable '", name, "' to grid")

func can_interact() -> bool:
	return true

func start_interaction():
	if not can_interact():
		print("WARNING: Cannot interact with '", name, "' - interaction blocked")
		return
	
	interaction_started.emit()



 
