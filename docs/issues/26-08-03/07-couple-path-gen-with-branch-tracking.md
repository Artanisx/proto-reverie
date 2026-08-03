# [REFACTOR] `generate_path()` couples path generation with branch candidate tracking

## Summary

`generate_path()` at `scenes/levels/base_procedural_level.gd:151-218` does two things:
1. Recursively builds the critical/branch path on the grid
2. Maintains `branch_candidates` by appending/removing positions (lines 205-206, 212)

These are separate concerns. The candidate list should be built as a post-process step after the critical path is finalized, making the recursive function simpler and easier to test in isolation.

## Affected File

`scenes/levels/base_procedural_level.gd`

## Current Code

```gdscript
func generate_path(from: Vector2i, length: int, marker: String) -> bool:
    # ... path building logic ...

    if length > 1 and length < critical_path_length:
        branch_candidates.append(current)  # side effect

    if generate_path(current, length - 1, marker):
        return true
    else:
        branch_candidates.erase(current)   # undo side effect
        room_map[current.x][current.y].room_identifier = ""
        current -= direction
```

## Proposed Fix

Separate path generation from candidate tracking:

```gdscript
func generate_critical_path() -> bool:
    """Returns true if a valid critical path was found."""
    return generate_path(start, critical_path_length, "CP")

func build_branch_candidates() -> void:
    """Post-process: find all rooms eligible for branch detours."""
    branch_candidates.clear()
    for x in dimensions.x:
        for y in dimensions.y:
            var info := room_map[x][y]
            if info.room_identifier.contains("CP"):
                # Check it's not start or end
                if info.room_identifier != "START" and \
                   not info.room_identifier.contains("ENDRO") and \
                   not info.room_identifier.contains("ENDBR"):
                    branch_candidates.append(Vector2i(x, y))

# In _ready():
generate_critical_path()
build_branch_candidates()
generate_branches()
```

Alternatively, pass the candidate array as a parameter to `generate_path()` so it doesn't mutate global state.

## Impact

- Makes `generate_path()` a pure function (easier to unit test)
- Decouples path generation from branch logic
- Allows reusing the critical path for other purposes (e.g., navigation, hints)
