extends Node2D
class_name NodeToGrid

# Tile size configuration (can be made configurable later)
@export var tile_size: int = 128

# Signal for when position is snapped to grid
signal position_snapped_to_grid(world_position: Vector2, tile_coordinates: Vector2i)

# Current tile coordinates
var current_tile: Vector2i

func _ready():
	# Initialize current tile
	current_tile = world_to_tile(global_position)

# Convert world position to tile coordinates
func world_to_tile(pos: Vector2) -> Vector2i:
	return Vector2i(floor(pos.x / tile_size), floor(pos.y / tile_size))

# Convert tile coordinates to world position (center of tile)
func tile_center_to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile.x * tile_size + tile_size / 2, tile.y * tile_size + tile_size / 2)

# Snap the parent node to the nearest tile center
func snap_parent_to_nearest_tile() -> Vector2:
	var nearest_tile = world_to_tile(get_parent().global_position)
	var tile_center = tile_center_to_world(nearest_tile)
	get_parent().global_position = tile_center
	
	# Update current tile
	current_tile = nearest_tile
	
	# Emit signal
	position_snapped_to_grid.emit(tile_center, nearest_tile)
	
	return tile_center

# Get the center position of the current tile
func get_current_tile_center() -> Vector2:
	return tile_center_to_world(current_tile)

# Get the tile coordinates for a given world position
func get_tile_coordinates(world_position: Vector2) -> Vector2i:
	return world_to_tile(world_position)

# Get the tile center for given tile coordinates
func get_tile_center(tile_coordinates: Vector2i) -> Vector2:
	return tile_center_to_world(tile_coordinates)

# Check if the parent has moved to a new tile
func check_tile_change() -> bool:
	var new_tile = world_to_tile(get_parent().global_position)
	if new_tile != current_tile:
		current_tile = new_tile
		return true
	return false

# Get the current tile coordinates
func get_current_tile() -> Vector2i:
	return current_tile

# Set tile size (useful for different grid sizes)
func set_tile_size(new_tile_size: int):
	tile_size = new_tile_size
	# Recalculate current tile with new size
	current_tile = world_to_tile(get_parent().global_position) 
