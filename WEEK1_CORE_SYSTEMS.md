# WEEK 1: CORE SYSTEMS - DETAILED IMPLEMENTATION GUIDE
=====================================================

## OVERVIEW
Week 1 focuses on establishing the foundational systems for our Yume Nikki style game using Godot 4.4. This week sets up the basic movement, navigation, and scene management systems.

---

## 1. PROJECT SETUP & CONFIGURATION
-----------------------------------

### 1.1 Godot 4.4 Project Configuration
- [x] **Engine Version**: Godot 4.4 (latest stable)
- [x] **Project Type**: 2D
- [x] **Renderer**: Mobile (for better performance on mobile devices)
- [x] **Platform Target**: iOS (primary), Android, PC

### 1.2 Screen Resolution & Scaling
```gdscript
# Project Settings Configuration
# Display -> Window -> Viewport
- [x] Viewport Width: 1080
- [x] Viewport Height: 1920
- [x] Stretch Mode: "canvas_items"
- [x] Stretch Aspect: "keep"
- [x] Stretch Scale: 1.0
```

### 1.3 Input Map Setup
Configure these input actions in Project Settings:
- [x] "left" -> A key, Left Arrow
- [x] "right" -> D key, Right Arrow  
- [x] "up" -> W key, Up Arrow
- [x] "down" -> S key, Down Arrow
- [x] "accept" -> Enter, Space
- [x] "cancel" -> Escape

---

## 2. PLAYER SYSTEM IMPLEMENTATION
---------------------------------

### 2.1 Player Scene Structure (Player.tscn)
- [x] Create Player (CharacterBody2D)
- [x] Add AnimatedSprite2D
- [x] Add CollisionShape2D
- [x] Add NavigationAgent2D
- [x] Add Camera2D

### 2.2 Player Script (Player.gd)
- [x] Create Player.gd script
- [x] Implement basic movement
- [x] tile-based movement with buffering
- [x] create a visual debug screen where we can see tiles and player movement
- [x] create a smooth movement experience
- [ ] Add 8-directional input handling
- [ ] Add animation system

### (later) 2.3 Click-to-Move Implementation
- [ ] Add mouse input handling
- [ ] Configure NavigationAgent2D
- [ ] Test click-to-move functionality

---

## 3. TOUCH CONTROLS SYSTEM
----------------------------

### (later) 3.1 TouchControls Scene Structure (TouchControls.tscn)
- [ ] Create TouchControls (Control)
- [ ] Add Joystick (Control)
- [ ] Add ActionButtons (HBoxContainer)
- [ ] Add InteractButton (TouchScreenButton)
- [ ] Add MenuButton (TouchScreenButton)

### (later) 3.2 Joystick Implementation
- [ ] Create TouchControls.gd script
- [ ] Implement joystick input handling
- [ ] Add touch event processing
- [ ] Test joystick functionality

### (later) 3.3 Touch Controls Integration
- [ ] Connect joystick to player
- [ ] Test touch controls on mobile
- [ ] Verify input responsiveness

---

## 4. TILEMAP & NAVIGATION SYSTEM
----------------------------------

### 4.1 TileMap Setup
- [ ] Create World (Node2D)
- [ ] Add TileMap
(later) - [ ] Add NavigationRegion2D 
- [ ] Add CollisionLayer

### 4.2 NavigationRegion2D Configuration
- [ ] Create AreaManager.gd script
- [ ] Implement navigation polygon generation
- [ ] Test pathfinding functionality

### 4.3 Animated Tiles Implementation
- [ ] Create AnimatedTileManager.gd script
- [ ] Implement animated tile system
- [ ] Test animated tiles

---

## 5. AREA MANAGEMENT SYSTEM
-----------------------------

### 5.1 AreaManager Script
- [ ] Create AreaManager.gd script
- [ ] Implement area loading system
- [ ] Add transition effects
- [ ] Test area transitions

---

## 6. HUB & TEST AREAS
-----------------------

### 6.1 Hub Scene (Hub.tscn)
- [ ] Create Hub (Node2D)
- [ ] Add TileMap
- [ ] Add NavigationRegion2D
- [ ] Add AreaPortals
- [ ] Add Player

### 6.2 Portal Implementation
- [ ] Create Portal.gd script
- [ ] Implement portal functionality
- [ ] Test area transitions

### 6.3 Test Areas Structure
- [ ] Create Area1.tscn
- [ ] Create Area2.tscn
- [ ] Add unique tilesets
- [ ] Add ambient audio

---

## 7. PROJECT STRUCTURE FOR WEEK 1
-----------------------------------

```
new-game-project/
├── scenes/
│   ├── Player.tscn
│   ├── Hub.tscn
│   ├── World/
│   │   ├── Area1.tscn
│   │   └── Area2.tscn
│   └── UI/
│       └── TouchControls.tscn
├── scripts/
│   ├── Player.gd
│   ├── AreaManager.gd
│   ├── TouchControls.gd
│   ├── Portal.gd
│   └── AnimatedTileManager.gd
├── assets/
│   ├── sprites/
│   │   ├── player/
│   │   └── tiles/
│   └── audio/
└── tilesets/
    ├── base_tileset.tres
    └── animated_tileset.tres
```

**Project Structure Tasks:**
- [ ] Create scenes/ directory
- [ ] Create scripts/ directory
- [ ] Create assets/ directory
- [ ] Create tilesets/ directory
- [ ] Create all required subdirectories

---

## 8. TESTING CHECKLIST
-----------------------

### 8.1 Movement Testing
- [ ] 8-directional movement works smoothly
- [ ] Diagonal movement speed is normalized
- [ ] Click-to-move navigation works
- [ ] Touch joystick responds correctly
- [ ] Player animations play correctly

### 8.2 Navigation Testing
- [ ] TileMap collision detection works
- [ ] NavigationAgent2D pathfinding functions
- [ ] Player can't walk through walls
- [ ] Smooth movement around obstacles

### 8.3 Area Management Testing
- [ ] Hub loads correctly
- [ ] Area transitions work
- [ ] Player position is maintained during transitions
- [ ] Fade transitions are smooth

### 8.4 Performance Testing
- [ ] 60 FPS on target devices
- [ ] Memory usage is reasonable
- [ ] No frame drops during movement
- [ ] Smooth scrolling and rendering

---

## 9. NEXT STEPS FOR WEEK 2
----------------------------

After completing Week 1, you'll have:
- [ ] Basic 8-directional movement system
- [ ] Click-to-move navigation
- [ ] Touch controls for mobile
- [ ] Area management system
- [ ] Hub and test areas
- [ ] Animated tiles foundation

**Week 2 will focus on:**
- [ ] Interaction system (objects, NPCs)
- [ ] Dialogue system
- [ ] Audio management
- [ ] More complex area designs

---

## 10. TROUBLESHOOTING COMMON ISSUES
-------------------------------------

### 10.1 Movement Issues
- **Problem**: Diagonal movement is faster
  - **Solution**: Ensure `Input.get_vector()` is used (automatically normalizes)
- **Problem**: Player gets stuck on tiles
  - **Solution**: Check collision shapes and navigation polygon generation

### 10.2 Navigation Issues
- **Problem**: Click-to-move doesn't work
  - **Solution**: Verify NavigationAgent2D is properly configured
- **Problem**: Pathfinding is jagged
  - **Solution**: Adjust NavigationAgent2D parameters

### 10.3 Touch Control Issues
- **Problem**: Joystick doesn't respond
  - **Solution**: Check input event handling and signal connections
- **Problem**: Touch area is wrong
  - **Solution**: Verify joystick positioning and radius calculation 