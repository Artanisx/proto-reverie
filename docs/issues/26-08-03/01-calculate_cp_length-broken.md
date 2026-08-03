# [BUG] calculate_cp_length() crashes on room identifiers

## Summary

`calculate_cp_length()` at `scenes/levels/base_procedural_level.gd:446-447` calls `int()` on the full room identifier string (e.g. `"CPL:L:13"`), which throws a parsing error. This function is called from `generate_level()` (lines 281-298) to validate adjacency of START and END rooms, meaning that entire validation branch is broken.

## Affected File

`scenes/levels/base_procedural_level.gd`

## Current Code

```gdscript
func calculate_cp_length(level_to_calculate: String) -> int:
    return int(level_to_calculate)
```

## Expected Behavior

The function should extract the numeric portion from identifiers like `"CPL:L:13"` and return `13`.

## Proposed Fix

Parse the number out of the string:

```gdscript
func calculate_cp_length(level_to_calculate: String) -> int:
    var parts := level_to_calculate.split(":")
    return int(parts[1])
```

## Impact

- START and END room adjacency checks in `generate_level()` silently fail or crash
- Rooms may be placed with incorrect door configurations at level edges
