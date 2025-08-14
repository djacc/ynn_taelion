class_name Interactable
extends Area2D

# Debug settings
@export var debug_prints: bool = true

# Interaction properties
@export var has_collision: bool = true

# Grid positioning
var node_to_grid: Node2D

# Interaction signal
signal interaction_started()

func _ready():
	# Setup grid positioning
	setup_node_to_grid()
	
	if debug_prints:
		print("DEBUG: Interactable _ready() called for: ", name)

func setup_node_to_grid():
	# Get reference to the NodeToGrid child node
	node_to_grid = $NodeToGrid
	
	# Snap interactable to grid
	var snapped_position = node_to_grid.snap_parent_to_nearest_tile()
	if debug_prints:
		print("Interactable snapped to grid at: ", snapped_position)

func can_interact() -> bool:
	return true

func start_interaction():
	if debug_prints:
		print("interacted with ", name)
	interaction_started.emit()



 
