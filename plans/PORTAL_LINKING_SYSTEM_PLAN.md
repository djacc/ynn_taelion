# Portal Linking System Plan

## Overview
Create a comprehensive portal system that allows portals to be linked between different worlds/scenes, with support for entrance/exit functionality, default spawn locations, and interactable integration.

## Core Requirements

### A. Default Spawn Location
- **Purpose**: Mark a portal as the default spawn point for a scene
- **Implementation**: Add `@export var is_default_spawn: bool = false` to Portal
- **Behavior**: When a world loads, default spawn portals automatically spawn the player
- **Validation**: Only one portal per world should be marked as default

### B. Portal Exit Functionality
- **Purpose**: Control whether a portal can be used for travel/exit
- **Behavior**:
  - **All portals are entrances**: Players can spawn at any portal
  - **Exit portals**: Controlled by `can_exit` boolean
  - **Simple setup**: Just check/uncheck "Can Exit" in inspector

### C. Portal Scene Linking
- **Purpose**: Connect portals to target scenes
- **Implementation**: Direct scene file reference system
- **Format**: Drag scene file into target_scene field (e.g., DebugPortal.tscn)

### D. Tile-Based Trigger System
- **Purpose**: Trigger portal travel when player walks onto portal tile
- **Implementation**: Area2D node in Portal scene with collision detection
- **Behavior**: Automatic travel when player enters portal tile (if can_exit = true)

## Technical Architecture

### 1. Portal.gd Enhancements

#### New Export Variables
```gdscript
# Portal behavior
@export var can_exit: bool = false  # Whether this portal can be used to exit/travel
@export var is_default_spawn: bool = false

# Scene linking configuration
@export var target_scene: PackedScene  # Drag the scene file here
@export var spawn_direction: SpawnDirection = SpawnDirection.SOUTH

# Interactable integration
@export var is_interactable_portal: bool = false
@export var interaction_text: String = "Travel"
```

#### New Methods
```gdscript
func get_linked_portal() -> Portal
func is_entrance_portal() -> bool
func is_exit_portal() -> bool
func can_spawn_here() -> bool
func can_travel_from_here() -> bool
func trigger_travel()
func validate_default_spawn()
```

### 2. Enhanced SpawnManager.gd (Combined System)

#### Purpose
Enhanced spawn manager that handles both spawning and portal travel logic.

#### New Core Functions
```gdscript
# Portal registration and lookup
func register_portal(portal: Portal, world_name: String)
func unregister_portal(portal: Portal, world_name: String)
func find_default_spawn_portal(world_name: String) -> Portal

# Travel logic
func travel_to_portal(from_portal: Portal, to_portal: Portal)
func travel_to_default_spawn(world_name: String)

# Portal validation
func validate_portal_links()
func validate_default_spawns()

# Enhanced spawning
func spawn_player_at_default_portal(world_name: String)
func spawn_player_at_specific_portal(world_name: String, portal_reference: String)
```

### 3. InteractablePortal.gd (New Component)

#### Purpose
Component that can be attached to any interactable to add portal functionality.

#### Implementation
```gdscript
class_name InteractablePortal
extends Node

@export var linked_portal: NodePath  # Direct reference to portal node in other scene
@export var interaction_text: String = "Travel"

func start_portal_interaction()
func can_travel() -> bool
```

### 4. InteractablePortal.gd (New Component)

#### Purpose
Component that can be attached to any interactable to add portal functionality.

#### Implementation
```gdscript
class_name InteractablePortal
extends Node

@export var linked_world: String = ""
@export var linked_portal_reference: String = ""
@export var interaction_text: String = "Travel"

func start_portal_interaction()
func can_travel() -> bool
```

## Implementation Phases

### Phase 1: Portal Type System
- [x] Add can_exit boolean to Portal.gd
- [x] Add is_default_spawn export variable
- [x] Implement portal behavior validation methods
- [x] Update portal initialization logic

### Phase 2: Enhanced SpawnManager System
- [x] Enhance SpawnManager.gd with portal registration
- [x] Add portal travel logic to SpawnManager
- [x] Implement default spawn portal management
- [x] Add portal validation and error handling
- [x] Integrate with existing spawn functionality

### Phase 3: InteractablePortal Integration
- [ ] Create InteractablePortal.gd component
- [ ] Implement interactable portal behavior
- [ ] Add interaction text and validation
- [ ] Integrate with InteractionManager

### Phase 4: Testing and Polish
- [ ] Test portal linking between DebugWorld and DebugPortal
- [ ] Test default spawn functionality
- [ ] Test interactable portal integration
- [ ] Add error handling and debug output



## Usage Examples

### Example 1: Basic Portal Scene Linking
```gdscript
# In DebugWorld.tscn - Portal setup
can_exit = true
target_scene = preload("res://scenes/World/DebugPortal.tscn")  # Drag scene file

# In DebugPortal.tscn - Portal setup
is_default_spawn = true
```

### Example 2: Interactable Portal
```gdscript
# Add InteractablePortal component to any interactable
linked_portal = NodePath("../DebugPortal/Portal")  # Reference to portal in other scene
interaction_text = "Enter Portal"
```

### Example 3: Default Spawn Travel
```gdscript
# Travel to default spawn of a world
PortalManager.travel_to_default_spawn("DebugPortal")
```

## File Structure Updates

```
new-game-project/
├── scripts/
│   ├── Portal.gd (enhanced)
│   ├── SpawnManager.gd (enhanced)
│   ├── InteractablePortal.gd (new)
├── scenes/
│   ├── World/
│   │   ├── DebugWorld.tscn
│   │   └── DebugPortal.tscn
│   └── Portal.tscn (updated)
```

## Implementation Decisions

1. **Portal Reference Format**: Direct NodePath reference to portal nodes in other scenes
2. **Default Spawn Validation**: Prevent multiple default spawns per world
3. **Interactable Integration**: Separate InteractablePortal component for easier implementation
4. **Travel Animation**: Instant travel (no animation for now)
5. **Error Handling**: Graceful error handling with debug output

## Next Steps

1. **Start with Phase 1 implementation**
2. **Test each phase before moving to the next**
3. **Implement error handling throughout** 