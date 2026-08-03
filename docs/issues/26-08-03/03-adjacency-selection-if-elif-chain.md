# [REFACTOR] Replace 50-line if/elif chain for room type selection

## Summary

`generate_level()` at `scenes/levels/base_procedural_level.gd:331-375` uses a 45-line cascade of if/elif statements to select a `RoomType` based on 4 boolean flags (`is_there_room_up/down/left/right`). This is brittle, unreadable, and impossible to extend without copying more branches.

## Affected File

`scenes/levels/base_procedural_level.gd`

## Current Code (excerpt)

```gdscript
if is_there_room_up and is_there_room_down and is_there_room_right and is_there_room_left:
    place_room(room_map[i][j].world_position, RoomType.R10x10_4W, kind)
elif is_there_room_up and is_there_room_down and not is_there_room_right and not is_there_room_left:
    place_room(room_map[i][j].world_position, RoomType.R10x10_2W_VERTICAL, kind)
elif not is_there_room_up and not is_there_room_down and is_there_room_right and is_there_room_left:
    place_room(room_map[i][j].world_position, RoomType.R10x10_2W_HORIZZONTAL, kind)
# ... 12 more elif branches
```

## Proposed Fix

Use a 4-bit bitmask to encode adjacency, then use a data-driven lookup table:

```gdscript
# Define bit positions: bit 0=down, bit 1=up, bit 2=left, bit 3=right
var bits := (1 if is_there_room_down else 0) | \
            (2 if is_there_room_up else 0) | \
            (4 if is_there_room_left else 0) | \
            (8 if is_there_room_right else 0)

const ADJACENCY_MAP := {
    0: null,                          # 0000 - no neighbors (shouldn't happen)
    1: RoomType.R10x10_1W_BOTTOM,     # 0001
    2: RoomType.R10x10_1W_TOP,        # 0010
    3: RoomType.R10x10_2W_VERTICAL,   # 0011
    4: RoomType.R10x10_1W_LEFT,       # 0100
    5: RoomType.R10x10_2W_BOTTOM_LEFT,# 0101
    6: RoomType.R10x10_2W_HORIZZONTAL,# 0110
    7: RoomType.R10x10_3W_BOTTOM,     # 0111
    8: RoomType.R10x10_1W_RIGHT,      # 1000
    9: RoomType.R10x10_2W_TOP_LEFT,   # 1001
    12: RoomType.R10x10_2W_BOTTOM_RIGHT,# 1100
    14: RoomType.R10x10_3W_TOP,       # 1110
    15: RoomType.R10x10_4W,           # 1111
    # ... etc
}

var room_type := ADJACENCY_MAP[bits]
if room_type != null:
    place_room(room_map[i][j].world_position, room_type, kind)
```

## Impact

- Reduces ~45 lines of conditional logic to a 15-entry data table
- Makes it trivial to add new room variants or change adjacency rules
- Eliminates risk of forgetting an edge case in a long if/elif chain
