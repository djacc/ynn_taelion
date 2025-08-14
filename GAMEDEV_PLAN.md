YUME NIKKI STYLE GAME DEV PLAN (GODOT 4)
=========================================

BASIC INFO:
-----------
- Engine: Godot 4
- Style: Top-down (3/4 perspective)
- Platform: iOS (primary), Android, PC
- Input: Touch-first (click-to-move, drag-to-move), occasional object interaction
- Assets: Custom (static + animated tiles)
- Audio: Music, ambience, sound effects per area
- Structure: Central hub + >10 areas
- Save system: Yes
- Logic: Node-based



- Timeline: ~3–4 weeks

PROJECT STRUCTURE:
------------------

/scenes/
  Hub.tscn
  Player.tscn
  World/
    Area1.tscn
    Area2.tscn
    ...

/tilesets/
  base_tileset.tres
  animated_tileset.tres

/assets/
  /sprites/
  /tiles/
  /audio/

/scripts/
  Player.gd
  AreaManager.gd
  InteractionManager.gd
  SaveManager.gd

/ui/
  DialogueBox.tscn
  TouchControls.tscn


WEEK 1: CORE SYSTEMS
--------------------

- Setup Godot 4 project
- Configure screen resolution and scaling (fixed viewport)
- Create Player.tscn with animated 8-directional movement
- Implement click-to-move using NavigationAgent2D
- Create drag-to-move joystick with TouchControls.tscn
- Design base tileset, animated tiles (via AnimatedTile or shader)
- Add TileMap + NavigationRegion2D for pathfinding
- Create AreaManager.gd to load areas with transitions
- Build Hub.tscn and two simple test areas


WEEK 2: INTERACTIONS & AUDIO
----------------------------

- Create Interactable.tscn (Area2D + Collision + Sprite/Label)
- Add InteractionManager.gd to handle tap/click logic
- Trigger interaction: play sound, show message, teleport, etc.
- Build DialogueBox.tscn with typewriter text animation
- Handle multiple messages in queue
- Create AudioManager.gd to manage:
  - Background music per area
  - Ambient sounds
  - Interaction SFX
- Smooth fade in/out when switching tracks


WEEK 3: CONTENT & SAVE SYSTEM
-----------------------------

- Expand Hub system: portals or doors to >5 areas
- Add logic to track which areas are unlocked
- Create SaveManager.gd:
  - Save: current map, player position, unlocked areas
  - Load on game start
- Use FileAccess to write/read from disk
- Start building out unique areas:
  - At least 5–7 with distinct tilemaps
  - Ambient, music, basic interactions


WEEK 4: POLISH & EXPORTS
-------------------------

- Add transition effects (fade in/out, visual polish)
- Add idle animations, extra sprite states
- Test on:
  - iOS (Apple cert needed)
  - Android
  - PC (windowed)
- Final pass:
  - Optimize for mobile (sprite resolution, visibility)
  - Fix touch UI quirks
  - Make sure game resumes correctly from save
  - Add secrets or effects if time permits


OPTIONAL BONUS (IF TIME):
-------------------------

- Random map changes or randomized NPCs
- Weather, screen filter effects
- Secret endings or narrative unlocks
- Light dream logic with unusual map connections 