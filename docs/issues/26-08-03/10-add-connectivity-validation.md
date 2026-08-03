# [FEATURE] Add post-generation connectivity validation

## Summary

The procedural generator creates a critical path and optional branches, which are guaranteed connected by construction. However, if generation fails partway (see issue #06) or if the algorithm is extended in the future, there's no guarantee that all placed rooms form a single connected component. A disconnected room means the player cannot reach it, which could hide important items, bosses, or exits.

## Affected File

`scenes/levels/base_procedural_level.gd`

## Proposed Implementation

Add a BFS flood-fill check after `generate_level()`:

```gdscript
func validate_connectivity() -> bool:
    """Returns true if all rooms are reachable from the start room."""
    var start_pos := _find_start_position()
    if start_pos == null:
        push_error("No start room found!")
        return false

    var visited := {}
    var queue := [start_pos]
    visited[start_pos] = true
    var total_rooms := 0

    while not queue.is_empty():
        var pos := queue.pop_front()
        total_rooms += 1

        # Check all 4 neighbors
        for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
            var neighbor := pos + dir
            if _is_valid_room_position(neighbor) and not visited.has(neighbor):
                var cell := room_map[neighbor.x][neighbor.y]
                if cell.room_identifier != "":
                    # Verify there's actually a door between them
                    if _has_door_between(pos, neighbor):
                        visited[neighbor] = true
                        queue.append(neighbor)

    return total_rooms == _count_total_rooms()

func _has_door_between(a: Vector2i, b: Vector2i) -> bool:
    """Check if room at 'a' has a door facing room at 'b'."""
    var room := room_map[a.x][a.y].room_instance
    if room == null:
        return false
    var diff := b - a
    match room.type:
        RoomType.R10x10_1W_TOP, RoomType.R10x10_2W_VERTICAL, RoomType.R10x10_2W_TOP_LEFT, \
        RoomType.R10x10_2W_TOP_RIGHT, RoomType.R10x10_3W_TOP, RoomType.R10x10_4W:
            if diff == Vector2i.UP: return true
        RoomType.R10x10_1W_BOTTOM, RoomType.R10x10_2W_VERTICAL, RoomType.R10x10_2W_BOTTOM_LEFT, \
        RoomType.R10x10_2W_BOTTOM_RIGHT, RoomType.R10x10_3W_BOTTOM, RoomType.R10x10_4W:
            if diff == Vector2i.DOWN: return true
        RoomType.R10x10_1W_LEFT, RoomType.R10x10_2W_HORIZZONTAL, RoomType.R10x10_2W_TOP_LEFT, \
        RoomType.R10x10_2W_BOTTOM_LEFT, RoomType.R10x10_3W_LEFT, RoomType.R10x10_4W:
            if diff == Vector2i.LEFT: return true
        RoomType.R10x10_1W_RIGHT, RoomType.R10x10_2W_HORIZZONTAL, RoomType.R10x10_2W_TOP_RIGHT, \
        RoomType.R10x10_2W_BOTTOM_RIGHT, RoomType.R10x10_3W_RIGHT, RoomType.R10x10_4W:
            if diff == Vector2i.RIGHT: return true
    return false

func _find_start_position() -> Vector2i:
    for x in dimensions.x:
        for y in dimensions.y:
            if room_map[x][y].room_identifier == "START":
                return Vector2i(x, y)
    return null

func _count_total_rooms() -> int:
    var count := 0
    for x in dimensions.x:
        for y in dimensions.y:
            if room_map[x][y].room_identifier != "":
                count += 1
    return count
```

## Integration

Add to `_ready()` after `check_generated_level()`:

```gdscript
generate_level()
check_generated_level()

if not validate_connectivity():
    push_error("Generated level has disconnected rooms! Retrying...")
    # Trigger retry (see issue #06)
```

## Impact

- Catches generation bugs that produce unreachable rooms
- Provides a safety net when the algorithm is extended
- Could be disabled in release builds for performance if needed
