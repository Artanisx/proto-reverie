# [REFACTOR] Replace string-based room identifiers with structured data

## Summary

Room identifiers are raw strings like `"CPL:L:13"`, `"B1ML2L:1"`, `"ENDBR1L:3"`, `"START"`, `"ENDRO"` and the code parses them with fragile string operations: `split("M")`, `split(":")`, `split("R")[1].split("L")[0]`, `contains("B")`, `contains("CP")`, `contains("ENDBR")`. This is scattered across `generate_path()`, `generate_level()`, `calculate_branch_length()`, and `is_this_same_branch()`.

## Affected File

`scenes/levels/base_procedural_level.gd`

## Current Code (examples)

```gdscript
# Line 191-199: parsing branch end identifier
var room_name: String = marker
var parts := room_name.split("M")
var branch_name: int = int(parts[0])
var parts2 := parts[1].split(":")
var branch_length_str := int(parts2[0])

# Line 303-314: parsing ENDBR identifier
var branch_room_name: String = room_map[i][j].room_identifier
var parts := branch_room_name.split(":")
var branch_num_name := parts[0].split("R")[1].split("L")[0]

# Line 267-270: checking room kind via string contains
elif room_map[i][j].room_identifier.contains("CP"):
    kind = BaseRoom.RoomKind.CRITICALPATH
```

## Proposed Fix

Create a value class to replace string identifiers:

```gdscript
class_name LevelRoomInfo:
    enum Kind { EMPTY, START, END, CRITICALPATH, BRANCHROOM, BRANCHPATHEND }

    var kind: Kind = Kind.EMPTY
    var branch_number: int = -1
    var remaining_length: int = 0

    func is_endpath() -> bool:
        return kind == Kind.START or kind == Kind.END or kind == Kind.BRANCHPATHEND

# Usage in room_map:
var room_map: Array[Array]  # instead of Array
# Each cell holds a LevelRoomInfo, not a RoomData with string identifier
```

Then adjacency checks become simple comparisons:

```gdscript
if room_info.kind == LevelRoomKind.CRITICALPATH:
    # no string parsing needed
```

## Impact

- Eliminates all `split()`, `contains()`, and index-based string parsing
- Makes room kind checks O(1) enum comparisons
- Prevents silent bugs from malformed identifiers
- Makes it trivial to add new room kinds
