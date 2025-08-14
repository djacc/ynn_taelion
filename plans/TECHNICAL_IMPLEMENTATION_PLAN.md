# Technical Implementation Plan - Core Building Blocks

## Overview
This plan outlines the technical implementation of all core systems needed to create a solid foundation for the game. Once these systems are in place, only world-specific content (assets, music, connections) will need to be added.

---

## 1. SCENE MANAGEMENT SYSTEM
-----------------------------

### 1.1 NodeToGrid.gd
**Purpose**: Generic grid utility node for tile-based positioning

**Core Functions**:
```gdscript
class_name NodeToGrid
extends Node2D

@export var tile_size: int = 128

func snap_parent_to_nearest_tile() -> Vector2
func get_current_tile() -> Vector2i
func get_current_tile_center() -> Vector2
func world_to_tile(pos: Vector2) -> Vector2i
func tile_center_to_world(tile: Vector2i) -> Vector2
func check_tile_change() -> bool
```

**Implementation Tasks**:
- [x] Create NodeToGrid class
- [x] Implement tile coordinate conversion
- [x] Add grid snapping functionality
- [x] Create reusable scene (NodeToGrid.tscn)
- [x] Integrate with Player and Portal systems

### 1.2 AreaManager.gd
**Purpose**: Central system for loading/unloading worlds and managing transitions

**Core Functions**:
```gdscript
class_name AreaManager
extends Node

signal world_loaded(world_name: String)
signal world_unloaded(world_name: String)

var current_world: Node = null
var worlds_data: Dictionary = {}
var debug_world_scene: PackedScene

func initialize_area_manager()
func initialize_debug_world()
func load_world(world_name: String)
func unload_current_world()
func get_current_world() -> Node
func get_current_world_name() -> String
func is_world_loaded(world_name: String) -> bool
```

**Implementation Tasks**:
- [x] Create AreaManager class
- [x] Implement basic world loading/unloading
- [x] Add DebugWorld scene management
- [x] Create world data tracking system
- [x] Add debug print controls
- [ ] Add transition effects (fade, instant, etc.)
- [ ] Handle player position persistence
- [ ] Add world state management
- [ ] Implement multiple world support

### 1.3 Portal.gd ✅ IMPLEMENTED
**Purpose**: Base class for world transition objects

**Core Functions**:
```gdscript
class_name Portal
extends Node2D

enum SpawnDirection { NORTH, SOUTH, EAST, WEST }
@export var spawn_direction: SpawnDirection = SpawnDirection.NORTH
@export var can_exit: bool = false
@export var is_default_spawn: bool = false
@export var target_scene_name: String = ""  # Type scene name here: "DebugPortal", "DebugWorld", etc.

signal portal_initialized(portal: Portal, spawn_position: Vector2, spawn_direction: Vector2)

func get_spawn_position() -> Vector2
func get_target_scene_name() -> String
func get_spawn_direction_vector() -> Vector2
func is_entrance_portal() -> bool
func is_exit_portal() -> bool
func can_spawn_here() -> bool
func can_travel_from_here() -> bool
func trigger_travel_to_scene()
```

**Implementation Tasks**:
- [x] Create Portal base class
- [x] Add NodeToGrid integration for grid positioning
- [x] Implement spawn position calculation
- [x] Add portal initialization signal system
- [x] Create Portal.tscn scene for easy placement

### 1.4 SpawnManager.gd
**Purpose**: Central system for managing player spawning at portal locations

**Core Functions**:
```gdscript
class_name SpawnManager
extends Node

@export var auto_spawn: bool = true
@export var default_spawn_reference: String = "default"

func setup_spawn_system()
func spawn_player_at_reference(spawn_reference: String)
func create_player_at_position(spawn_position: Vector2, source_portal: Portal)
func spawn_player()
func find_portals_in_current_world() -> Array[Portal]
func connect_to_world_portals()
```

**Implementation Tasks**:
- [x] Create SpawnManager singleton
- [x] Implement dynamic portal discovery
- [x] Add auto-spawn functionality
- [x] Create dynamic player instantiation
- [x] Add manual spawn capability
- [x] Integrate with Portal signal system
- [x] Integrate with AreaManager for world transitions

### 1.5 TransitionSystem.gd
**Purpose**: Handle smooth transitions between worlds

**Core Functions**:
```gdscript
class_name TransitionSystem
extends CanvasLayer

signal transition_finished()

func fade_out(duration: float = 1.0)
func fade_in(duration: float = 1.0)
func instant_transition()
func custom_transition(transition_name: String)
```

**Implementation Tasks**:
- [ ] Create transition overlay
- [ ] Implement fade effects
- [ ] Add custom transition types
- [ ] Handle transition timing
- [ ] Add loading screen support

---

## 2. PLAYER SYSTEM ENHANCEMENTS
---------------------------------

### 2.1 Player State Management
**Current**: Basic movement ✅
**Needed**: State machine for different player states

**States**:
- **Idle**: Standing still, no input
- **Walking**: Moving in any direction
- **Interacting**: Performing an interaction
- **Transitioning**: Moving between worlds

**Implementation Tasks**:
- [x] Create PlayerState enum
- [x] Add state machine to Player.gd
- [x] Implement state-specific behaviors
- [x] Add state transition animations
- [x] Handle state persistence across worlds

### 2.2 Player Position Persistence
**Purpose**: Remember player position in each world

**Core Functions**:
```gdscript
# In Player.gd
var world_positions: Dictionary = {}

func save_position_in_world(world_name: String)
func load_position_in_world(world_name: String) -> Vector2
func set_spawn_position(world_name: String, position: Vector2)
```

**Implementation Tasks**:
- [x] Add position tracking per world
- [x] Implement position saving/loading
- [x] Add spawn point system
- [x] Handle world-specific starting positions

---

## 3. INTERACTION SYSTEM
------------------------

### 3.1 Interactable.gd ✅ IMPLEMENTED
**Purpose**: Base class for all interactive objects

**Core Functions**:
```gdscript
class_name Interactable
extends Area2D

signal interaction_started()

@export var debug_prints: bool = true
@export var interaction_text: String = "Press E to interact"
@export var interaction_distance: float = 64.0

var node_to_grid: Node2D

func can_interact() -> bool
func start_interaction()
func get_interaction_prompt() -> String
func setup_node_to_grid()
```

**Implementation Tasks**:
- [x] Create Interactable base class
- [x] Add collision detection
- [x] Implement interaction logic
- [x] Add visual feedback system
- [x] Create interaction prompt system
- [x] Add NodeToGrid integration for tile centering
- [x] Add debug print controls

### 3.2 InteractionManager.gd ✅ IMPLEMENTED
**Purpose**: Central system for handling all interactions

**Core Functions**:
```gdscript
class_name InteractionManager
extends Node

signal interaction_available(interactable: Interactable)
signal interaction_unavailable()
signal interaction_started(interactable: Interactable)
signal interaction_ended()

var current_interactable: Interactable = null
var interaction_queue: Array[Interactable] = []
var is_interaction_active: bool = false

func register_interactable(interactable: Interactable)
func unregister_interactable(interactable: Interactable)
func trigger_interaction() -> bool
func update_current_interactable()
func get_current_interactable() -> Interactable
func has_interaction_available() -> bool
func clear_all_interactables()
```

**Implementation Tasks**:
- [x] Create InteractionManager singleton
- [x] Implement interaction detection
- [] Add interaction queue system
- [] Handle multiple interactables
- [x] Add input handling for interactions
- [] Integrate with Player and Interactable classes
- [] Add auto-registration system for interactables

### 3.3 DialogueSystem.gd
**Purpose**: Handle text display and dialogue management

**Core Functions**:
```gdscript
class_name DialogueSystem
extends CanvasLayer

signal dialogue_started()
signal dialogue_ended()
signal text_completed()

var dialogue_queue: Array = []
var is_dialogue_active: bool = false
var current_text: String = ""
var text_speed: float = 0.05

func start_dialogue(dialogue_data: Dictionary)
func add_to_queue(dialogue_data: Dictionary)
func advance_dialogue()
func skip_dialogue()
func end_dialogue()
```

**Implementation Tasks**:
- [ ] Create DialogueBox UI
- [ ] Implement typewriter text effect
- [ ] Add dialogue queue system
- [ ] Handle dialogue branching
- [ ] Add text speed controls

---

## 4. AUDIO SYSTEM
------------------

### 4.1 AudioManager.gd
**Purpose**: Central audio management for music, ambience, and SFX

**Core Functions**:
```gdscript
class_name AudioManager
extends Node

signal music_changed(track_name: String)
signal ambience_changed(ambience_name: String)

var current_music: String = ""
var current_ambience: String = ""
var music_volume: float = 0.7
var sfx_volume: float = 1.0
var ambience_volume: float = 0.5

func play_music(track_name: String, fade_duration: float = 1.0)
func play_ambience(ambience_name: String, fade_duration: float = 2.0)
func play_sfx(sfx_name: String, volume: float = 1.0)
func stop_music(fade_duration: float = 1.0)
func set_volume(type: String, volume: float)
```

**Implementation Tasks**:
- [ ] Create AudioManager singleton
- [ ] Implement music system with fading
- [ ] Add ambience system
- [ ] Create SFX management
- [ ] Add volume controls
- [ ] Implement audio pooling for performance

### 4.2 World-Specific Audio
**Purpose**: Different audio per world

**Implementation Tasks**:
- [ ] Create audio data structure per world
- [ ] Implement automatic audio switching
- [ ] Add crossfade between tracks
- [ ] Handle audio persistence

---

## 5. SAVE SYSTEM
-----------------

### 5.1 SaveManager.gd
**Purpose**: Save and load game progress

**Core Functions**:
```gdscript
class_name SaveManager
extends Node

signal save_completed()
signal load_completed()

var save_data: Dictionary = {}
var save_file_path: String = "user://savegame.save"

func save_game()
func load_game()
func has_save_file() -> bool
func delete_save_file()
func get_save_data() -> Dictionary
func set_save_data(data: Dictionary)
```

**Save Data Structure**:
```gdscript
var save_data = {
    "player": {
        "world_positions": {},
        "inventory": [],
        "flags": {}
    },
    "worlds": {
        "unlocked_worlds": [],
        "world_states": {}
    },
    "game_progress": {
        "current_world": "",
        "play_time": 0,
        "completed_events": []
    }
}
```

**Implementation Tasks**:
- [ ] Create SaveManager singleton
- [ ] Implement save/load functions
- [ ] Add save data validation
- [ ] Create auto-save system
- [ ] Add save file management

---

## 6. UI SYSTEM
---------------

### 6.1 HUD.gd
**Purpose**: Basic heads-up display

**Core Functions**:
```gdscript
class_name HUD
extends CanvasLayer

signal interaction_prompt_shown()
signal interaction_prompt_hidden()

func show_interaction_prompt(text: String)
func hide_interaction_prompt()
func update_hud_elements()
func show_notification(message: String, duration: float = 3.0)
```

**Implementation Tasks**:
- [ ] Create HUD scene
- [ ] Add interaction prompt display
- [ ] Implement notification system
- [ ] Add basic UI elements
- [ ] Create UI animations

### 6.2 MenuSystem.gd
**Purpose**: Handle pause menu and settings

**Core Functions**:
```gdscript
class_name MenuSystem
extends CanvasLayer

signal menu_opened()
signal menu_closed()

func open_pause_menu()
func close_pause_menu()
func open_settings()
func apply_settings()
```

**Implementation Tasks**:
- [ ] Create pause menu
- [ ] Add settings menu
- [ ] Implement menu navigation
- [ ] Add settings persistence
- [ ] Create menu animations

---

## 7. WORLD CONNECTION SYSTEM
------------------------------

### 7.1 World Connection Types

**A. Direct Teleporters**
- Physical objects in the world
- Instant world switching
- Visual feedback (glow, particles)

**B. Transition Zones**
- Invisible areas that trigger world changes
- Automatic detection
- Smooth transitions

**C. Door/Entrance System**
- Physical door objects
- Unlock conditions
- Visual door states (open/closed/locked)

### 7.2 World Connection Implementation

**Portal Types**:
```gdscript
# Direct Teleporter
class_name Teleporter
extends Portal

func _ready():
    interaction_type = "teleport"
    add_glow_effect()
    add_particle_effect()

# Transition Zone
class_name TransitionZone
extends Area2D

@export var target_world: String
@export var fade_duration: float = 1.0

func _on_body_entered(body: Node2D):
    if body is Player:
        AreaManager.load_world(target_world)

# Door System
class_name Door
extends Interactable

@export var is_locked: bool = false
@export var required_item: String = ""
@export var target_world: String = ""

func can_interact() -> bool:
    return !is_locked or Player.has_item(required_item)

func start_interaction():
    if is_locked:
        DialogueSystem.start_dialogue({"text": "The door is locked."})
    else:
        AreaManager.load_world(target_world)
```

---

## 8. IMPLEMENTATION PHASES
---------------------------

### Phase 1: Core Systems (Week 1) - ✅ COMPLETED
- [x] NodeToGrid system for grid-based positioning
- [x] Portal system for spawn point management
- [x] SpawnManager for dynamic player spawning
- [x] Player grid-based movement system
- [x] Basic scene management with portal-driven spawning

### Phase 2: World Management (Week 2) - 🔄 IN PROGRESS
- [x] AreaManager for scene loading/unloading
- [x] Multiple world support (DebugWorld, DebugPortal)
- [ ] TransitionSystem for smooth world transitions
- [ ] World connection system

### Phase 3: Interaction and UI (Week 3) - 🔄 IN PROGRESS
- [x] Interactable base class implementation
- [x] Raycast-based interaction detection
- [x] Player facing direction system
- [x] Test interactable scene and integration
- [x] InteractionManager implementation
- [ ] DialogueSystem
- [ ] HUD and menu systems
- [ ] Interaction polish

### Phase 4: Audio and Save (Week 4)
- [ ] AudioManager implementation
- [ ] SaveManager implementation
- [ ] Performance optimization
- [ ] Testing and bug fixes

### Phase 5: Content Creation (Week 5+)
- [ ] Create world assets
- [ ] Add music and sound effects
- [ ] Design world connections
- [ ] Content testing and refinement

---

## 9. FILE STRUCTURE
--------------------

```
new-game-project/
├── scenes/
│   ├── Player.tscn ✅
│   ├── Portal.tscn ✅
│   ├── NodeToGrid.tscn ✅
│   ├── main.tscn ✅
│   ├── UI/
│   │   ├── HUD.tscn
│   │   ├── DialogueBox.tscn
│   │   ├── PauseMenu.tscn
│   │   └── SettingsMenu.tscn
│   ├── Interactables/
│   │   ├── Door.tscn
│   │   └── TransitionZone.tscn
│   └── Worlds/
│       ├── World1.tscn
│       └── World2.tscn
├── scripts/
│   ├── Core/
│   │   ├── AreaManager.gd ✅
│   │   ├── AudioManager.gd
│   │   ├── SaveManager.gd
│   │   └── InteractionManager.gd ✅
│   ├── Player/
│   │   ├── Player.gd ✅
│   │   └── PlayerState.gd
│   ├── UI/
│   │   ├── HUD.gd
│   │   ├── DialogueSystem.gd
│   │   └── MenuSystem.gd
│   ├── Interactables/
│   │   ├── Interactable.gd ✅
│   │   ├── Portal.gd ✅
│   │   ├── Door.gd
│   │   └── TransitionZone.gd
│   └── Systems/
│       ├── SpawnManager.gd ✅
│       ├── NodeToGrid.gd ✅
│       ├── TransitionSystem.gd
│       └── NotificationSystem.gd
├── assets/
│   ├── audio/
│   │   ├── music/
│   │   ├── sfx/
│   │   └── ambience/
│   ├── sprites/
│   │   ├── player/
│   │   ├── ui/
│   │   └── interactables/
│   └── tilesets/
│       ├── world1_tileset.tres
│       └── world2_tileset.tres
└── data/
    ├── world_data.json
    ├── dialogue_data.json
    └── audio_data.json
```

---

## 10. TESTING CHECKLIST
-------------------------

### Core Systems Testing - ✅ COMPLETED
- [x] Portal positioning and grid snapping works correctly
- [x] Player spawns at portal location automatically
- [x] Grid-based movement system functions properly
- [x] NodeToGrid utility works with multiple objects
- [x] SpawnManager correctly manages player instantiation

### Current Testing Status
- [x] Portal initialization and signal emission
- [x] SpawnManager portal selection and auto-spawn
- [x] Player grid alignment and movement
- [x] Dynamic player creation at portal positions
- [x] Manual spawn functionality (R key)
- [x] AreaManager world loading and initialization
- [x] DebugWorld scene management
- [x] World data tracking and state management

### Remaining Testing
- [x] World loading/unloading works correctly
- [ ] Player position persists across worlds
- [ ] Transitions are smooth and reliable
- [ ] Audio switches properly between worlds
- [ ] Save/load system functions correctly

### Interaction Testing
- [x] All interactables respond to input
- [x] Raycast detection works correctly
- [x] Player facing direction updates properly
- [x] Interaction input (E key) triggers correctly
- [x] Test interactable prints debug messages
- [x] InteractionManager handles interaction logic
- [x] Auto-registration system works
- [x] Centralized interaction management
- [ ] Dialogue system displays text correctly
- [ ] Interaction prompts show/hide properly
- [ ] Portal transitions work as expected

### Performance Testing
- [ ] 60 FPS maintained during transitions
- [ ] Memory usage stays reasonable
- [ ] Audio doesn't cause frame drops
- [ ] Save/load operations are fast

### Cross-Platform Testing
- [ ] Works on PC (keyboard/mouse)
- [ ] Works on mobile (touch controls)
- [ ] UI scales properly on different resolutions
- [ ] Audio works on all target platforms 