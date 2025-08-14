# Audio System Plan

## Overview
Implement a modular audio system with a global AudioManager and per-world audio setups.

## Architecture

### 1. Global AudioManager
- **Location**: Main scene
- **Purpose**: Main orchestrator for playing music and sound effects
- **Responsibilities**:
  - Manage global audio settings
  - Coordinate between different world audio systems
  - Handle audio transitions
  - Control master volume

### 2. WorldAudio (Per-World Audio Control)
- **Location**: Each world scene as a Control node
- **Purpose**: Local audio management for each world
- **Structure**:
  ```
  WorldAudio (Control)
  ├── BGM (AudioStreamPlayer)
  └── SFX (AudioStreamPlayer)
  ```
- **Responsibilities**:
  - Manage local BGM and SFX nodes
  - Expose volume controls as export variables
  - Handle world-specific audio logic

### 3. Audio File Organization
```
assets/audio/
├── world1/
│   ├── bgm/
│   └── sfx/
├── world2/
│   ├── bgm/
│   └── sfx/
└── [additional worlds...]
```

## Implementation Steps

### Phase 1: Core Audio System
1. Create `AudioManager.gd` script
2. Create `WorldAudio.gd` script
3. Set up audio node structure in world scenes
4. Create audio folder structure
5. Implement basic play/stop functionality

### Phase 2: Integration (Future)
1. Integrate with AreaManager for area-specific music
2. Add player action sound effects
3. Implement audio transitions and fading
4. Add audio settings persistence

## Script Structure

### AudioManager.gd
```gdscript
class_name AudioManager
extends Node

# Global audio management
# - Master volume control
# - Audio state management
# - Coordination between worlds
```

### WorldAudio.gd
```gdscript
class_name WorldAudio
extends Control

# Per-world audio control
# - BGM and SFX volume controls
# - Local audio playback
# - Integration with AudioManager
```

## File Structure
```
scripts/
├── AudioManager.gd
└── WorldAudio.gd

scenes/
├── Main/
│   └── Main.tscn (contains AudioManager)
└── World/
    ├── World1.tscn (contains WorldAudio)
    └── World2.tscn (contains WorldAudio)

assets/audio/
├── world1/
│   ├── bgm/
│   └── sfx/
└── world2/
    ├── bgm/
    └── sfx/
```

## Design Principles
- **Modularity**: Each world manages its own audio independently
- **Centralized Control**: AudioManager orchestrates global audio decisions
- **Extensibility**: Easy to add new worlds and audio features
- **Debug-Friendly**: Export variables for easy testing and adjustment 