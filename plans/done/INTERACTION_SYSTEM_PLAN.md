# Interaction System Implementation Plan

## **Goal:**
Create raycast-based interaction detection with a base Interactable class that prints "interacted with X" when pressing E/Enter.

## **Simple Actionable Steps:**

### **Step 1: Create Base Interactable Class**
- [x] Create `scripts/Interactable.gd`
- [x] Extend `Area2D`
- [x] Add basic properties (`interaction_text`, `interaction_distance`)
- [x] Add `can_interact()`, `start_interaction()`, `get_interaction_prompt()` functions
- [x] Add signal `interaction_started()`

### **Step 2: Add Facing Direction to Player**
- [x] Add `facing_direction: Vector2` variable to Player.gd
- [x] Add `get_facing_direction() -> Vector2` function
- [x] Update facing direction based on movement direction
- [x] Set default facing direction (Vector2.DOWN)
- [x] Add `get_facing_direction_name() -> String` for debug prints

### **Step 3: Add Interaction Detection to Player**
- [x] Add `current_interactable: Interactable` variable
- [x] Create `check_interaction_in_front() -> Interactable` function
- [x] Use raycast to detect Interactable in facing direction
- [x] Set interaction distance to 128 pixels (2 tiles)
- [x] Add `update_raycast_direction()` for automatic direction updates
- [x] Move raycast from code to scene node (InteractionRaycast)

### **Step 4: Add Interaction Input Handling**
- [x] Add interaction input handling in Player's `_input()` function
- [x] Check for "interact" action (E key)
- [x] Call `check_interaction_in_front()` when E is pressed
- [x] Call `interactable.start_interaction()` if found

### **Step 5: Create Test Interactable Scene**
- [x] Create `scenes/Interactable/TestInteractable.tscn`
- [x] Add Area2D node with Interactable.gd script
- [x] Add CollisionShape2D child
- [x] Set up collision shape (small square)
- [x] Add debug print in `start_interaction()`
- [x] Add NodeToGrid child for tile centering
- [x] Configure collision layers/masks for raycast detection

### **Step 6: Add Test Interactable to World**
- [x] Add TestInteractable to DebugWorld scene
- [x] Position it in front of player spawn point
- [x] Test interaction by pressing E
- [x] Configure collision layers/masks for proper detection

### **Step 7: Add Debug Prints**
- [x] Add debug prints for interaction detection
- [x] Add debug prints for facing direction
- [x] Add debug prints for raycast results
- [x] Add debug prints for raycast direction updates
- [x] Add debug prints for interactable detection

## **Expected Result:**
- Player faces direction of movement
- Press E near interactable → prints "interacted with TestInteractable"
- Raycast detects interactable 2 tiles in front of player
- Raycast direction updates automatically with movement
- Clean, simple interaction system ready for expansion

## **Files to Create/Modify:**
- `scripts/Interactable.gd` (new) ✅
- `scripts/Player.gd` (modify) ✅
- `scenes/Interactable/TestInteractable.tscn` (new) ✅
- `scenes/World/DebugWorld.tscn` (modify) ✅
- `scenes/Player.tscn` (modify - added InteractionRaycast node) ✅

## **Technical Details:**

### **Raycast Detection:**
```gdscript
func check_interaction_in_front() -> Interactable:
    # Force raycast update
    interaction_raycast.force_raycast_update()
    
    if interaction_raycast.is_colliding() and interaction_raycast.get_collider() is Interactable:
        return interaction_raycast.get_collider()
    return null

func update_raycast_direction():
    # Update raycast direction based on facing direction
    interaction_raycast.target_position = facing_direction * 128  # 2 tiles
```

### **Base Interactable Class:**
```gdscript
class_name Interactable
extends Area2D

@export var interaction_text: String = "Press E to interact"
@export var interaction_distance: float = 64.0

signal interaction_started()

func can_interact() -> bool:
    return true

func start_interaction():
    print("interacted with ", name)
    interaction_started.emit()

func get_interaction_prompt() -> String:
    return interaction_text
```

### **Player Integration:**
```gdscript
# In Player.gd
var facing_direction: Vector2 = Vector2.DOWN
var interaction_raycast: RayCast2D

func _input(event):
    if event.is_action_pressed("interact"):
        var interactable = check_interaction_in_front()
        if interactable and interactable.can_interact():
            interactable.start_interaction()

func update_raycast_direction():
    interaction_raycast.target_position = facing_direction * 128
```

## **Next Steps After Completion:**
1. **Dialogue System**: Add text-based interactions
2. **Visual Feedback**: Add interaction prompts and highlights
3. **Multiple Interaction Types**: Teleporters, item pickups, doors
4. **Interaction Manager**: Central system for managing all interactions
5. **UI Integration**: Add interaction prompts to HUD 