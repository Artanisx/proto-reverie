# Reverie Proto - Godot Script Documentation

## Table of Contents
| # | File | Class | Description |
|---|------|-------|-------------|
| 1 | `scenes/levels/base_level.gd` | BaseLevel | Base level class, handles player spawning |
| 2 | `scenes/levels/base_procedural_level.gd` | BaseProceduralLevel | Procedural dungeon generator |
| 3 | `scenes/rooms/base_room.gd` | BaseRoom | Base room with ceiling auto-fill |
| 4 | `scenes/rooms/room_data.gd` | RoomData | Data container for a room in the level grid |
| 5 | `scenes/world/proto_world.gd` | World | Top-level scene controller, minimap setup |
| 6 | `scenes/ui/minimap_camera.gd` | MinimapCamera | Camera that follows player on minimap |
| 7 | `scenes/characters/player/player.gd` | Player | FPS character controller |
| 8 | `scenes/characters/components/equipment_component.gd` | EquipmentComponent | Handles equipped weapon display & animation |
| 9 | `scenes/equipment/equipped_item.gd` | EquippedItem | Node for a currently-equipped weapon mesh |
| 10 | `scenes/equipment/pickable_item.gd` | PickableItem | Node for a floor item that can be picked up |
| 11 | `data/weapon_data.gd` | WeaponData | Resource defining weapon stats |

---

## 1. BaseLevel (`scenes/levels/base_level.gd`)

**Inherits:** `Node3D`

Base class for all levels. Responsible for spawning the Player at the designated spawn point.

### Exported/Member Variables
| Variable | Type | Description |
|----------|------|-------------|
| `player` | `Player` | Reference to the instantiated player |

### OnReady Variables
| Variable | Type | Description |
|----------|------|-------------|
| `player_spawn` | `Node3D` | `%PlayerSpawn` - spawn position marker |

### Constants
| Constant | Value |
|----------|-------|
| `PLAYER_PREFAB` | `res://scenes/characters/player/player.tscn` |

### Functions
| Function | Returns | Description |
|----------|---------|-------------|
| `_ready()` | `void` | Instantiates the player scene, sets its global transform to `player_spawn`, and adds it as a child |
| `get_player()` | `Player` | Returns the instantiated player reference |

---

## 2. BaseProceduralLevel (`scenes/levels/base_procedural_level.gd`)

**Inherits:** `BaseLevel`

Procedurally generates a dungeon level by placing rooms on a 2D grid. Uses a recursive backtracking algorithm to generate a critical path from entrance to exit, with optional branch detours. After generating the logical grid, it instantiates actual room scenes and fixes door mismatches.

### Enums
**RoomType** - Defines all 15 room variants by door count and configuration:
- `R10x10_1W_BOTTOM`, `R10x10_1W_LEFT`, `R10x10_1W_RIGHT`, `R10x10_1W_TOP` (1-door rooms)
- `R10x10_2W_BOTTOM_LEFT`, `R10x10_2W_BOTTOM_RIGHT`, `R10x10_2W_HORIZZONTAL`, `R10x10_2W_TOP_LEFT`, `R10x10_2W_TOP_RIGHT`, `R10x10_2W_VERTICAL` (2-door rooms)
- `R10x10_3W_BOTTOM`, `R10x10_3W_LEFT`, `R10x10_3W_RIGHT`, `R10x10_3W_TOP` (3-door rooms)
- `R10x10_4W` (4-door room)

### Exported Variables
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `dimensions` | `Vector2i` | `(7, 5)` | Grid size of the level |
| `start` | `Vector2i` | `(-1, -1)` | Start room position. If invalid, a random position is chosen |
| `critical_path_length` | `int` | `13` | Minimum rooms from start to end |
| `branches` | `int` | `3` | Number of detour branches |
| `branch_length` | `Vector2i` | `(1, 4)` | Min/max rooms per branch |
| `room_size` | `int` | `21` | Physical size of each room in world units (includes door portions) |

### Member Variables
| Variable | Type | Description |
|----------|------|-------------|
| `room_map` | `Array` | 2D array of `RoomData`, mirrors the level grid structure |
| `branch_candidates` | `Array[Vector2i]` | Grid positions of rooms eligible for branch detours |

### Constants
| Constant | Description |
|----------|-------------|
| `ROOMS_MAP` | Dictionary mapping each `RoomType` to its preloaded `.tscn` scene path |
| `MINIMAP_ICONS_HEIGHT` | Y position (3.5) for minimap sprite icons |

### OnReady Variables
| Variable | Type | Description |
|----------|------|-------------|
| `rooms_container` | `Node3D` | `$Rooms` - parent node for all placed room instances |

### Functions (Generation Pipeline)
| Function | Description |
|----------|-------------|
| `_ready()` | Calls: `initialize_level()` -> `place_entrance()` -> `generate_path()` -> `generate_branches()` -> debug prints -> `calculate_room_positions()` -> `generate_level()` -> `check_generated_level()` -> `super()` |
| `initialize_level()` | Creates a 2D array of empty `RoomData` objects matching `dimensions` |
| `place_entrance()` | Validates/assigns start position, marks it as `"START"` in the grid |
| `generate_path(from, length, marker)` | Recursive backtracking: picks random directions, places rooms along a path. Returns `true` on success. Marks end rooms as `"ENDRO"` or `"ENDBR"`. Adds intermediate positions to `branch_candidates` |
| `generate_branches()` | Iterates until all branches are created. Picks a random candidate, generates a detour path with marker `"B{N}ML{L}"` |
| `calculate_room_positions()` | Fills `world_position` for each cell: `(x * room_size, y * room_size)` |
| `generate_level()` | Main room placement. For each occupied cell, determines adjacency (up/down/left/right), selects the matching `RoomType`, calls `place_room()`. Stores room instance references back into `room_map` |
| `place_room(position, type, kind)` | Instantiates the room scene from `ROOMS_MAP`, sets position/kind/type, calls `place_room_nodes()`, adds to `rooms_container`, returns the room |
| `place_room_nodes(room)` | Adds special nodes based on room kind: END = blue light + minimap icon; START = green light + minimap icon; BRANCHPATHEND = red light + minimap icon |
| `check_generated_level()` | Post-generation fixup. Iterates special rooms (START/END/BRANCHPATHEND), calls `check_neighboors()` to ensure adjacent rooms don't have doors facing closed walls |
| `check_neighboors(x, y, r_type)` | For each of 4 neighbors of a special room, checks if the neighbor's door direction is valid given the special room's open side. Calls `check_neighboor()` |
| `check_neighboor(pos, up/down/left/right_forbidden)` | If a neighbor has a forbidden door, replaces it with a reduced-door variant (4W->3W->2W->1W). Frees old instance and places new one |
| `calculate_cp_length(s)` | Parses critical path length from identifier string |
| `calculate_branch_length(branch_num, room_id)` | Returns branch length if the room belongs to the same branch; returns 999 to fail adjacency check otherwise |
| `is_this_same_branch(branch_num, room_id)` | Checks if `room_id` belongs to branch `branch_num`. Handles `"ENDBR"` end rooms (always false) |
| `is_endpath_room(s)` | Returns true if string contains `"START"`, `"ENDRO"`, or `"ENDBR"` |

### Debug Functions
| Function | Description |
|----------|-------------|
| `print_level()` | Prints room identifiers as `[IDENT]` or `[     ]` (top-to-bottom, left-to-right) |
| `print_level_map()` | Same but includes coordinates: `[IDENT](x,y)` |
| `print_level_grid()` | Prints world positions `[Vector2i]` |
| `reverse_print_level()` | Mirrored view (right-to-left X) matching game viewport |
| `reverse_print_level_map()` | Mirrored with identifiers and coordinates |
| `reverse_print_level_grid()` | Mirrored world positions |
| `print_rooms()` | Prints placed rooms with kind labels and world positions |

---

## 3. BaseRoom (`scenes/rooms/base_room.gd`)

**Inherits:** `Node3D`

Base room class. Automatically fills ceiling tiles at runtime based on which floor tiles lack ceilings.

### Enums
**RoomKind**: `START`(0), `END`(1), `CRITICALPATH`(2), `BRANCHROOM`(3), `BRANCHPATHEND`(4)

### Member Variables
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `kind` | `RoomKind` | `START` | Room role in the level |
| `type` | `RoomType` | `R10x10_4W` | Room door configuration |
| `cell_ids_with_no_ceiling` | `Array` | `[]` | Floor tile IDs that need ceiling tiles |

### OnReady Variables
| Variable | Type | Description |
|----------|------|-------------|
| `ceilings` | `GridMap` | `%Ceilings` |
| `floors` | `GridMap` | `%Floors` |

### Functions
| Function | Returns | Description |
|----------|---------|-------------|
| `_ready()` | `void` | Calls `fill_ceilings()` |
| `fill_ceilings()` | `void` | Identifies floor tiles without ceilings (`Ground`, `Hole-Corner`, `Hole-Side`, `Hole-UTurn`), then iterates all used floor cells and paints ceiling tiles (id 0) on matching positions in the `ceilings` GridMap |

---

## 4. RoomData (`scenes/rooms/room_data.gd`)

**Inherits:** `RefCounted`

Plain data container for a room within the procedural level grid. Used to track identifiers, world positions, and instantiated room references.

### Member Variables
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `room_identifier` | `String` | `""` | Room name, e.g. `"START"`, `"CP:13"`, `"ENDBR:1:2:2"` |
| `world_position` | `Vector2i` | `(0,0)` | World-space position of the room |
| `room_instance` | `BaseRoom` | `null` | Reference to the instantiated room scene |

### Functions
| Function | Returns | Description |
|----------|---------|-------------|
| `_init(identifier, position, instance)` | `void` | Constructor. Initializes all three member variables from parameters (or defaults) |

---

## 5. World (`scenes/world/proto_world.gd`)

**Inherits:** `Node3D`

Top-level scene controller. Sets up the minimap camera to track the player once the procedural level is ready.

### OnReady Variables
| Variable | Type | Description |
|----------|------|-------------|
| `minimap_camera` | `MinimapCamera` | `$MarginContainer/PanelContainer/Minimap/SubViewport/MinimapCamera` |
| `test_procedural_level` | `BaseProceduralLevel` | `$TestProceduralLevel` |

### Functions
| Function | Returns | Description |
|----------|---------|-------------|
| `_ready()` | `void` | Connects `minimap_camera.minimap_ready` signal to `on_minimap_ready()` |
| `on_minimap_ready()` | `void` | Calls `minimap_camera.set_player(test_procedural_level.get_player())` |

---

## 6. MinimapCamera (`scenes/ui/minimap_camera.gd`)

**Inherits:** `Camera3D`

Camera that follows the player on the minimap sub-view. Maintains a fixed offset from the player's position.

### Member Variables
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `player` | `Player` | `null` | Reference to the tracked player |
| `offset` | `Vector3` | — | Fixed offset between camera and player position |

### Signals
| Signal | Description |
|--------|-------------|
| `minimap_ready` | Emitted when the camera is ready (emitted in `_ready()` and when player is null in `_process()`) |

### Functions
| Function | Returns | Description |
|----------|---------|-------------|
| `set_player(player_set)` | `void` | Sets the tracked player and calculates the initial offset |
| `_ready()` | `void` | Emits `minimap_ready`, then sets offset if player exists |
| `_process(_delta)` | `void` | Updates camera global position to `player.global_position + offset`. If no player is set, re-emits `minimap_ready` |

---

## 7. Player (`scenes/characters/player/player.gd`)

**Inherits:** `CharacterBody3D`

First-person character controller handling movement, jumping, mouse look, and item interaction.

### Constants
| Constant | Value | Description |
|----------|-------|-------------|
| `MAX_ANGLE_LOOK_UP` | `deg_to_rad(70)` | Maximum upward camera rotation |
| `MAX_ANGLE_LOOK_DOWN` | `deg_to_rad(-70)` | Maximum downward camera rotation |

### Exported Variables
| Variable | Type | Description |
|----------|------|-------------|
| `acceleration` | `float` | Movement acceleration/friction. Recommended: `walk_speed * 10` |
| `jump_force` | `float` | Jump intensity |
| `gravity` | `float` | Gravity force applied when airborne |
| `mouse_sensitivity` | `float` | Mouse look speed multiplier |
| `run_speed` | `float` | WASD+SHIFT movement speed |
| `walk_speed` | `float` | WASD movement speed |
| `mapcamera_distance` | `float` | `100.0` - Minimap camera Y zoom distance |

### OnReady Variables
| Variable | Type | Description |
|----------|------|-------------|
| `animation_player` | `AnimationPlayer` | `$character/AnimationPlayer` |
| `camera` | `Camera3D` | `%Camera3D` - FPS camera |
| `mapcamera` | `Camera3D` | `$MAPCAMERA` - Minimap camera |
| `select_raycast` | `RayCast3D` | `%SelectRaycast` - Picks up objects |
| `equipment` | `EquipmentComponent` | `%EquipmentComponent` |

### Member Variables
| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `current_pickable_focused_item` | `PickableItem` | `null` | Currently raycast-targeted pickable item |
| `input_dir` | `Vector2` | `ZERO` | WASD input direction |
| `mouse_look_allowed` | `bool` | `true` | Toggles mouse look (disabled when minimap is active) |

### Functions
| Function | Returns | Description |
|----------|---------|-------------|
| `_ready()` | `void` | Captures mouse mode, sets minimap camera size |
| `_process(_delta)` | `void` | Reads WASD input via `Input.get_vector()`. Checks "use" action (E key) and calls `pickup_object()` if an item is in range |
| `_physics_process(delta)` | `void` | Calls `check_jump_input()`, `process_gravity()`, calculates 3D velocity from input direction, applies acceleration/deceleration via `move_toward()`, plays run/idle animation, calls `move_and_slide()`, checks for item selection |
| `_input(event)` | `void` | Handles PageUp/PageDown to switch between FPS and minimap cameras. Processes `InputEventMouseMotion` for camera rotation (Y-axis for player yaw, X-axis for camera pitch with clamping) |
| `check_jump_input()` | `void` | Applies `jump_force` if on floor and jump action pressed |
| `process_gravity()` | `void` | Subtracts `gravity` from Y velocity when not on floor |
| `check_for_selection()` | `void` | Checks `select_raycast` collision. If targeting a different `PickableItem` than before, calls `unhighlight()` on old and `highlight()` on new |
| `can_pickup_object()` | `bool` | Returns true if an item is currently focused |
| `pickup_object()` | `void` | Calls `equipment.equip_weapon()` with the item's weapon data and transform, then queues free of the pickable item |

---

## 8. EquipmentComponent (`scenes/characters/components/equipment_component.gd`)

**Inherits:** `Node3D`

Handles equipping weapons on a player or enemy. Instantiates `EquippedItem` scenes and animates pickup from ground to hand.

### Exported Variables
| Variable | Type | Description |
|----------|------|-------------|
| `is_always_in_front` | `bool` | If true, weapon uses ZClip material (for player FPS view only) |
| `weapon_data` | `WeaponData` | Initial weapon data to equip |
| `weapon_placeholder` | `Node3D` | Attachment point where the weapon is parented |

### Constants
| Constant | Value |
|----------|-------|
| `EQUIPPED_ITEM_PREFAB` | `res://scenes/equipment/equipped_item.tscn` |

### Functions
| Function | Returns | Description |
|----------|---------|-------------|
| `_ready()` | `void` | If `weapon_data` is set, calls `equip_weapon(weapon_data)` |
| `equip_weapon(data, pickup_transform)` | `void` | Duplicates the `WeaponData` resource (to avoid shared state between entities), instantiates `EquippedItem`, configures it, adds to `weapon_placeholder`. If `pickup_transform` is provided, sets weapon to ground position and animates to hand |
| `animate_to_hand(equipped_item)` | `void` | Tween: position moves to `(0,0,0)` in 0.4s, rotation moves to `(0,0,0)` in 0.2s. Both parallel with `TRANS_QUAD` / `EASE_OUT` |

---

## 9. EquippedItem (`scenes/equipment/equipped_item.gd`)

**Inherits:** `Node3D`

Represents a weapon currently equipped by the player. Instantiates the weapon mesh and optionally applies ZClip material for FPS rendering.

### Exported Variables
| Variable | Type | Description |
|----------|------|-------------|
| `is_always_in_front` | `bool` | If true, weapon mesh is rendered in front of everything (FPS view) |
| `weapon_data` | `WeaponData` | The weapon's data resource |

### Constants
| Constant | Value |
|----------|-------|
| `ZCLIP_MATERIAL` | `res://materials/zclip_material.tres` |

### Functions
| Function | Returns | Description |
|----------|---------|-------------|
| `_ready()` | `void` | Instantiates the weapon mesh from `weapon_data.glb_mesh`, adds as child. If `is_always_in_front` is true, applies a **duplicated** `ZCLIP_MATERIAL` to the first child's `material_override` |

---

## 10. PickableItem (`scenes/equipment/pickable_item.gd`)

**Inherits:** `Area3D`

Represents a weapon lying on the ground that the player can pick up. Handles mesh instantiation, collision shape, and highlight feedback.

### Exported Variables
| Variable | Type | Description |
|----------|------|-------------|
| `weapon_data` | `WeaponData` | The weapon's data resource |

### Constants
| Constant | Value |
|----------|-------|
| `HIGHLIGHT_MATERIAL` | `res://materials/highlight_material.tres` (yellow albedo) |

### Member Variables
| Variable | Type | Description |
|----------|------|-------------|
| `highlight_material` | `StandardMaterial3D` | Duplicated highlight material for yellow glow |
| `mesh_node` | `MeshInstance3D` | Reference to the instantiated weapon mesh |

### OnReady Variables
| Variable | Type | Description |
|----------|------|-------------|
| `collision_shape` | `CollisionShape3D` | `%CollisionShape` - created dynamically from mesh bounds |

### Functions
| Function | Returns | Description |
|----------|---------|-------------|
| `_ready()` | `void` | Duplicates `HIGHLIGHT_MATERIAL`, instantiates weapon mesh from `weapon_data.glb_mesh`, creates convex collision shape from the mesh geometry |
| `highlight()` | `void` | Sets mesh `material_override` to highlight material (not duplicated - shared reference) |
| `unhighlight()` | `void` | Resets `material_override` to `null`, restoring original material |

---

## 11. WeaponData (`data/weapon_data.gd`)

**Inherits:** `Resource`

Data-only resource defining weapon statistics. Used by `EquipmentComponent`, `EquippedItem`, and `PickableItem`.

### Exported Variables
| Variable | Type | Description |
|----------|------|-------------|
| `name` | `String` | Weapon name |
| `condition` | `int` | Current durability |
| `max_condition` | `int` | Maximum durability |
| `damage_min` | `int` | Minimum damage |
| `damage_max` | `int` | Maximum damage |
| `reach` | `float` | Swing range |
| `throw_rotation_speed` | `float` | Airborne rotation speed |
| `throw_movement_speed` | `float` | Airborne movement speed |
| `glb_mesh` | `PackedScene` | `.glb` weapon model scene |

### Functions
| Function | Returns | Description |
|----------|---------|-------------|
| `get_damage_dealt()` | `int` | Returns random damage between `damage_min` and `damage_max` |
| `decrease_condition(amount)` | `void` | Reduces `condition` by `amount`, clamped to `[0, max_condition]` |
