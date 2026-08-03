# [BUG] No retry mechanism when procedural generation fails

## Summary

If `generate_path()` returns false (no valid path found via backtracking), the recursion unwinds and the function returns false. There's no top-level retry or restart mechanism. If random choices lead to an unsolvable state, the level generation silently produces an incomplete or broken grid. For a procedural/roguelike game, this means players could get stuck in unrecoverable states.

## Affected File

`scenes/levels/base_procedural_level.gd`

## Current Code

```gdscript
func _ready() -> void:
    initialize_level()
    place_entrance()
    generate_path(start, critical_path_length, "CP")  # result ignored!
    generate_branches()                                # result ignored!
    # ... continues even if generation failed ...
```

The return value of `generate_path()` is checked inside the recursion (line 208-218), but the top-level call in `_ready()` ignores it entirely. If the critical path generation fails partway, `branch_candidates` may be empty or incomplete, and `generate_branches()` will do nothing.

## Proposed Fix

Wrap the generation pipeline in a retry loop:

```gdscript
func _ready() -> void:
    var max_attempts := 50
    for attempt in range(max_attempts):
        initialize_level()
        branch_candidates.clear()

        if not place_entrance():
            continue

        if generate_path(start, critical_path_length, "CP"):
            generate_branches()
            calculate_room_positions()
            generate_level()
            check_generated_level()
            break  # success

        if attempt == max_attempts - 1:
            push_error("Failed to generate level after %d attempts" % max_attempts)
```

## Impact

- Prevents silent generation failures from producing broken levels
- Gives the algorithm multiple chances to find a valid configuration
- Should be paired with a connectivity validation check (see issue #08)
