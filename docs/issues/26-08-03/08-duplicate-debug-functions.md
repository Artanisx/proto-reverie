# [COSPAT] Consolidate 7 nearly-identical debug print functions

## Summary

There are 6 debug print functions that all do the same nested loop with minor formatting differences:

| Function | Lines | Format | Direction |
|----------|-------|--------|-----------|
| `print_level()` | 91-104 | `[IDENT]` or `[     ]` | Normal (L->R) |
| `print_level_map()` | 107-120 | `[IDENT](x,y)` | Normal (L->R) |
| `print_level_grid()` | 123-132 | `[Vector2i]` | Normal (L->R) |
| `reverse_print_level()` | 806-820 | `[IDENT]` or `[     ]` | Reversed (R->L) |
| `reverse_print_level_map()` | 823-837 | `[IDENT](x,y)` | Reversed (R->L) |
| `reverse_print_level_grid()` | 840-850 | `[Vector2i]` | Reversed (R->L) |

They share the same Y loop, the same empty-cell check, and differ only in cell formatting and X direction.

## Affected File

`scenes/levels/base_procedural_level.gd`

## Proposed Fix

Consolidate into a single parameterized function:

```gdscript
enum PrintFormat { ID, MAP, GRID }

func _print_level(format: PrintFormat, reverse_x: bool = false) -> void:
    var result := ""
    for y in range(dimensions.y - 1, -1, -1):
        var x_range := range(dimensions.x) if not reverse_x else range(dimensions.x - 1, -1, -1)
        for x in x_range:
            match format:
                PrintFormat.ID:
                    result += ("[" + room_map[x][y].room_identifier + "]") \
                              if room_map[x][y].room_identifier != "" else "[     ]"
                PrintFormat.MAP:
                    if room_map[x][y].room_identifier != "":
                        result += "[" + room_map[x][y].room_identifier + "](" + str(x) + "," + str(y) + ")"
                    else:
                        result += "[" + str(x) + "," + str(y) + "]"
                PrintFormat.GRID:
                    result += "[" + str(room_map[x][y].world_position) + "]"
        result += '\n'
    print(result)

# Replace all 6 functions with:
func print_level() -> void: _print_level(PrintFormat.ID, false)
func print_level_map() -> void: _print_level(PrintFormat.MAP, false)
func print_level_grid() -> void: _print_level(PrintFormat.GRID, false)
func reverse_print_level() -> void: _print_level(PrintFormat.ID, true)
func reverse_print_level_map() -> void: _print_level(PrintFormat.MAP, true)
func reverse_print_level_grid() -> void: _print_level(PrintFormat.GRID, true)
```

## Impact

- Reduces ~80 lines of duplicated code to ~25
- Single place to fix formatting bugs
- Easy to add new formats (e.g., JSON export)
