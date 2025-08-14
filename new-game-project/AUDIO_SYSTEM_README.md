# Audio System Documentation

## Overview
The audio system consists of two main components:
- **AudioManager**: Global orchestrator for audio across all worlds
- **WorldAudio**: Per-world audio control with BGM and SFX nodes

## Setup Instructions

### 1. Add AudioManager to Main Scene
1. Open your main scene (e.g., `scenes/Main/Main.tscn`)
2. Add a Node as a child of the root
3. Name it "AudioManager"
4. Attach the `AudioManager.gd` script to it
5. Add it to the "audio_manager" group

### 2. Add WorldAudio to World Scenes
1. Open a world scene (e.g., `scenes/World/DebugWorld.tscn`)
2. Add a Control node as a child of the root
3. Name it "WorldAudio"
4. Attach the `WorldAudio.gd` script to it
5. Add it to the "world_audio" group

### 3. Audio File Organization
```
assets/audio/
├── world1/
│   ├── bgm/
│   │   └── [your bgm files]
│   └── sfx/
│       └── [your sfx files]
├── world2/
│   ├── bgm/
│   └── sfx/
└── [additional worlds...]
```

## Usage Examples

### Playing Audio from Code
```gdscript
# Get references
var world_audio = get_node("../WorldAudio")
var audio_manager = get_node("/root/AudioManager")

# Play BGM with fade in
world_audio.play_bgm(your_bgm_stream, true)

# Play SFX
world_audio.play_sfx(your_sfx_stream)

# Stop BGM with fade out
world_audio.stop_bgm(true)
```

### Using AudioManager Globally
```gdscript
# Play audio through the global manager
audio_manager.play_bgm(your_bgm_stream)
audio_manager.play_sfx(your_sfx_stream)

# Control volumes
audio_manager.update_master_volume(0.8)
audio_manager.update_bgm_volume(0.6)
audio_manager.update_sfx_volume(1.0)
```

### Volume Controls
The WorldAudio node exposes these export variables for easy adjustment:
- `bgm_volume`: Background music volume (0.0 to 1.0)
- `sfx_volume`: Sound effects volume (0.0 to 1.0)
- `fade_duration`: Duration of fade transitions

## Audio Node Structure
```
WorldAudio (Control)
├── BGM (AudioStreamPlayer) - Background music
└── SFX (AudioStreamPlayer) - Sound effects
```

## Features
- **Fade Transitions**: Smooth volume transitions for BGM
- **Volume Control**: Individual control for BGM and SFX
- **Global Management**: AudioManager coordinates between worlds
- **Debug Support**: Extensive debug output for troubleshooting
- **Modular Design**: Each world manages its own audio independently

## Testing
Use the `AudioExample.gd` script to test the audio system:
- Press **Enter** to play SFX
- Press **Escape** to stop BGM
- Press **Space** to restart BGM

## Integration with AreaManager (Future)
The system is designed to integrate with your AreaManager for area-specific music. This will be implemented in Phase 2 of the audio system plan.

## Troubleshooting
1. **No Audio Playing**: Check that AudioManager is in the scene and WorldAudio is properly registered
2. **Volume Issues**: Verify volume settings in both AudioManager and WorldAudio nodes
3. **Missing Audio Files**: Ensure audio files are properly imported and assigned to streams 