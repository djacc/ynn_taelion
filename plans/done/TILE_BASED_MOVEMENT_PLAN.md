# HYBRID TILE-BASED MOVEMENT PLAN (WITH SNAPPING)
==================================================

## OVERVIEW
This document details the implementation plan for a hybrid tile-based movement system where the player moves smoothly between tile centers while respecting a 32x32 pixel grid.

---

## CORE PRINCIPLES
- Player movement is restricted to the grid: only one tile at a time, in cardinal directions.
- Input is only accepted when the player is perfectly centered on a tile.
- When a direction is pressed, the player moves smoothly to the center of the next tile in that direction.
- Player always ends up perfectly centered on a tile (snapping).
- Movement is blocked if the next tile is not walkable.
- Tile size is 32x32 pixels.

---

## KEY VARIABLES
```gdscript
var tile_size = 128
var current_tile: Vector2i  # Player's current tile
var target_tile: Vector2i   # Tile to move to
var is_moving: bool         # Whether the player is currently moving
var move_speed: float       # Pixels per second
```

---

## MOVEMENT LOGIC
1. **On input**, if not moving, check if the next tile is walkable.
2. **If so**, set `target_tile` and start moving.
3. **Move smoothly** toward the center of `target_tile`.
4. **When reaching the center**, snap to it, update `current_tile`, and allow new input.

---

## HELPER FUNCTIONS

### `world_to_tile(pos: Vector2) -> Vector2i`
Converts world position to tile coordinates.
```gdscript
func world_to_tile(pos: Vector2) -> Vector2i:
    return Vector2i(round(pos.x / tile_size), round(pos.y / tile_size))
```

### `tile_to_world(tile: Vector2i) -> Vector2`
Converts tile coordinates to world position (center of tile).
```gdscript
func tile_to_world(tile: Vector2i) -> Vector2:
    return Vector2(tile.x * tile_size + tile_size / 2, tile.y * tile_size + tile_size / 2)
```

### `snap_to_tile(tile: Vector2i)`
Snaps player position to the center of a specific tile.
```gdscript
func snap_to_tile(tile: Vector2i):
    global_position = tile_to_world(tile)
```

### `is_tile_walkable(tile: Vector2i) -> bool`
Checks if a tile is walkable (for collision detection).
```gdscript
func is_tile_walkable(tile: Vector2i) -> bool:
    # TODO: Implement collision detection with TileMap
    # For now, allow movement to any tile
    return true
```

---

## INPUT HANDLING
```gdscript
func handle_input():
    var dir = Vector2i.ZERO
    if Input.is_action_just_pressed("up"):
        dir = Vector2i(0, -1)
    elif Input.is_action_just_pressed("down"):
        dir = Vector2i(0, 1)
    elif Input.is_action_just_pressed("left"):
        dir = Vector2i(-1, 0)
    elif Input.is_action_just_pressed("right"):
        dir = Vector2i(1, 0)
    
    if dir != Vector2i.ZERO:
        var next_tile = current_tile + dir
        if is_tile_walkable(next_tile):
            target_tile = next_tile
            is_moving = true
```

---

## MOVEMENT EXECUTION
```gdscript
func move_towards_target_tile(delta):
    var target_pos = tile_to_world(target_tile)
    var direction = (target_pos - global_position).normalized()
    var distance = move_speed * delta
    
    if global_position.distance_to(target_pos) <= distance:
        global_position = target_pos
        current_tile = target_tile
        is_moving = false
    else:
        global_position += direction * distance
```

---

## INITIALIZATION
```gdscript
func _ready():
    current_tile = world_to_tile(global_position)
    snap_to_tile(current_tile)
```

---

## MAIN LOOP
```gdscript
func _physics_process(delta):
    if is_moving:
        move_towards_target_tile(delta)
    else:
        handle_input()
```

---

## ADVANTAGES
- ✅ **Smooth movement** - Natural feeling animation
- ✅ **Tile-respecting** - Can't walk through walls
- ✅ **Precise positioning** - Always centered on tiles
- ✅ **Mobile-friendly** - Works well with touch controls
- ✅ **Retro feel** - Classic grid-based movement
- ✅ **Flexible** - Can adjust speed and movement style

---

## FUTURE ENHANCEMENTS
- **Diagonal movement** - Add support for 8-directional movement
- **Animation integration** - Sync player animations with movement
- **Sound effects** - Add footstep sounds per tile
- **Visual feedback** - Highlight walkable tiles
- **Pathfinding** - Integrate with NavigationAgent2D for complex paths 