# 8-Directional Movement System Plan

## Requirements
1. **Movement Style**: Center-to-center tile movement
2. **Input**: Arrow keys + WASD for 8 directions
3. **Speed**: Same speed for diagonal and cardinal directions
4. **Continuous Movement**: Holding direction continues movement
5. **Collision**: Ignore for now
6. **Animation**: Ignore for now
7. **Speed**: Fixed speed
8. **Tile Size**: Fixed at 128px

## Architecture

### Current Implementation
- **Player (CharacterBody2D)**: Handles input detection and tile utilities
- **DirectionFinder (Node)**: Manages movement stack, direction calculation, and raycast control
- **Raycasts**: 8 RayCast2D nodes as children of DirectionFinder

### Communication Flow
1. **Player** detects input in `_input()`
2. **Player** calls `DirectionFinder.add_input_action()` or `DirectionFinder.remove_input_action()`
3. **DirectionFinder** updates movement stack and calculates direction
4. **DirectionFinder** enables/disables appropriate raycasts

## Current State Analysis

### What We Have So Far
- **Player.gd**: Simplified to handle only input and tile utilities
- **DirectionFinder.gd**: Complete movement stack management and direction calculation
- **Player Scene**: DirectionFinder node with 8 raycasts as children
- **Tile Utilities**: 
  - `world_to_tile(pos: Vector2) -> Vector2i`: Converts world position to tile coordinates
  - `tile_center_to_world(tile: Vector2i) -> Vector2`: Converts tile coordinates to world center position
  - `snap_to_nearest_tile()`: Snaps player to nearest tile center
- **Movement Logic**: Complete stack-based direction calculation with diagonal support

### What We Need to Implement
1. **Actual Movement**: Center-to-center movement with fixed speed
2. **Movement State**: Track current movement progress
3. **Continuous Movement**: Maintain movement when key is held

## Movement Direction Logic
- **1 Direction**: Use as-is (cardinal)
- **2 Directions**: Form diagonal or use newer direction if cancelling
- **3 Directions**: Cancel pairs, use remaining direction
- **4+ Directions**: Stay idle

## Next Steps
1. Implement actual movement system
2. Add movement state tracking
3. Add continuous movement support
4. Test and refine

---
*Last Updated: [Current Date]* 