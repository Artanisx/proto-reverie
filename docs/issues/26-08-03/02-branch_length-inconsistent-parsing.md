# [BUG] calculate_branch_length() parsing is inconsistent with calculate_cp_length()

## Summary

`calculate_branch_length()` at `scenes/levels/base_procedural_level.gd:449-464` correctly splits on `":"` and accesses index `[1]`, but `calculate_cp_length()` does not. The two functions handle the same identifier format inconsistently, and the branch length function also has fragile string parsing for the "same branch" check.

## Affected File

`scenes/levels/base_procedural_level.gd`

## Current Code

```gdscript
func calculate_branch_length(branch_number_name: String, level_to_calculate: String) -> int:
    if is_this_same_branch(branch_number_name, level_to_calculate):
        var parts := level_to_calculate.split(":")
        return int(parts[1])
    else:
        return 999

func is_this_same_branch(branch_number_name: String, room_to_check : String) -> bool:
    if room_to_check.contains("ENDBR"):
        return false
    var room_belongs_to_branch := room_to_check.split("M")[0][1]
    if branch_number_name == room_belongs_to_branch:
        return true
    else:
        return false
```

## Proposed Fix

Either fix `calculate_cp_length()` to match this pattern, or unify both functions under a single parser. Consider extracting branch number and length into a helper:

```gdscript
func parse_branch_info(identifier: String) -> Dictionary:
    if not identifier.contains("B"):
        return {"branch": -1, "length": 0}
    var parts := identifier.split(":")
    var branch_part := parts[0].split("M")[0]
    return {
        "branch": int(branch_part[1]),
        "length": int(parts[1]) if parts.size() > 1 else 0
    }
```

## Impact

If `calculate_cp_length()` is fixed, both functions will share the same parsing logic and should be consolidated to avoid future divergence.
