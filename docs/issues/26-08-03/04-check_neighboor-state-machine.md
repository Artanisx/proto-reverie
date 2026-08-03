# [REFACTOR] Replace 160-line check_neighboor() conditional state machine with data-driven lookup

## Summary

`check_neighboors()` and `check_neighboor()` at `scenes/levels/base_procedural_level.gd:587-803` contain ~160 lines of nested conditionals that determine which room type to swap in when a door direction is forbidden. The logic is: "if direction D is forbidden and current room type is X, replace with type Y." This is encoded as giant match/if chains inside each direction branch.

## Affected File

`scenes/levels/base_procedural_level.gd`

## Current Code (excerpt)

```gdscript
func check_neighboor(room_pos: Vector2i, up_forbidden, down_forbidden, left_forbidden, right_forbidden) -> void:
    # ... boundary checks ...

    if up_forbidden:
        if neigh_type == RoomType.R10x10_2W_TOP_LEFT:
            neigh_instance.queue_free()
            place_room(neigh_pos, RoomType.R10x10_1W_LEFT, neigh_kind)
        elif neigh_type == RoomType.R10x10_2W_TOP_RIGHT:
            neigh_instance.queue_free()
            place_room(neigh_pos, RoomType.R10x10_1W_RIGHT, neigh_kind)
        elif neigh_type == RoomType.R10x10_2W_VERTICAL:
            neigh_instance.queue_free()
            place_room(neigh_pos, RoomType.R10x10_1W_BOTTOM, neigh_kind)
        elif neigh_type == RoomType.R10x10_3W_LEFT:
            neigh_instance.queue_free()
            place_room(neigh_pos, RoomType.R10x10_2W_BOTTOM_LEFT, neigh_kind)
        # ... 10+ more branches per direction
    elif down_forbidden:
        # ... 10+ more branches ...
    elif left_forbidden:
        # ... 10+ more branches ...
    elif right_forbidden:
        # ... 10+ more branches ...
```

## Proposed Fix

Data-driven replacement table. Define which room types are invalid when a door in direction D is forbidden:

```gdscript
const REPLACEMENT_FOR_UP_FORBIDDEN := {
    RoomType.R10x10_2W_TOP_LEFT:   RoomType.R10x10_1W_LEFT,
    RoomType.R10x10_2W_TOP_RIGHT:  RoomType.R10x10_1W_RIGHT,
    RoomType.R10x10_2W_VERTICAL:   RoomType.R10x10_1W_BOTTOM,
    RoomType.R10x10_3W_LEFT:       RoomType.R10x10_2W_BOTTOM_LEFT,
    RoomType.R10x10_3W_RIGHT:      RoomType.R10x10_2W_BOTTOM_RIGHT,
    RoomType.R10x10_3W_TOP:        RoomType.R10x10_2W_HORIZZONTAL,
    RoomType.R10x10_4W:            RoomType.R10x10_3W_BOTTOM,
}

const REPLACEMENT_FOR_DOWN_FORBIDDEN := {
    RoomType.R10x10_2W_BOTTOM_LEFT:   RoomType.R10x10_1W_LEFT,
    RoomType.R10x10_2W_BOTTOM_RIGHT:  RoomType.R10x10_1W_RIGHT,
    RoomType.R10x10_2W_VERTICAL:      RoomType.R10x10_1W_TOP,
    RoomType.R10x10_3W_BOTTOM:        RoomType.R10x10_2W_HORIZZONTAL,
    RoomType.R10x10_3W_LEFT:          RoomType.R10x10_2W_TOP_LEFT,
    RoomType.R10x10_3W_RIGHT:         RoomType.R10x10_2W_TOP_RIGHT,
    RoomType.R10x10_4W:               RoomType.R10x10_3W_TOP,
}

# ... similar tables for LEFT and RIGHT forbidden ...
```

Then `check_neighboor()` becomes:

```gdscript
func check_neighboor(room_pos: Vector2i, up_forbidden, down_forbidden, left_forbidden, right_forbidden) -> void:
    # ... boundary checks ...
    if not up_forbidden and not down_forbidden and not left_forbidden and not right_forbidden:
        return

    var replacement_table := _get_replacement_table(up_forbidden, down_forbidden, left_forbidden, right_forbidden)
    if neigh_type in replacement_table:
        var new_type := replacement_table[neigh_type]
        neigh_instance.queue_free()
        place_room(neigh_pos, new_type, neigh_kind)

func _get_replacement_table(up_f, down_f, left_f, right_f) -> Dictionary:
    if up_f: return REPLACEMENT_FOR_UP_FORBIDDEN
    if down_f: return REPLACEMENT_FOR_DOWN_FORBIDDEN
    if left_f: return REPLACEMENT_FOR_LEFT_FORBIDDEN
    if right_f: return REPLACEMENT_FOR_RIGHT_FORBIDDEN
    return {}
```

## Impact

- Reduces ~160 lines of duplicated conditionals to 4 small lookup tables (~30 lines total)
- Makes it trivial to verify correctness (each replacement is a single line)
- Eliminates risk of missing or duplicating a branch
