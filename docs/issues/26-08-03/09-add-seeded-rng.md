# [FEATURE] Add deterministic seeding for reproducible levels

## Summary

The procedural level generator uses `randi_range()` everywhere but has no seed parameter. Each playthrough generates a completely random dungeon with no way to reproduce a specific layout. For a roguelike/procedural game, this is a common feature players expect.

## Affected File

`scenes/levels/base_procedural_level.gd`

## Current State

```gdscript
# No seed anywhere. Random calls:
match randi_range(0, 3):          # line 170
direction = Vector2i.UP/DOWN/LEFT/RIGHT

candidate = branch_candidates[randi_range(0, branch_candidates.size() - 1)]  # line 228

start.x = randi_range(0, dimensions.x - 1)  # line 138
```

## Proposed Implementation

```gdscript
@export var seed: int = -1  # -1 = random, any other value = fixed seed

func _ready() -> void:
    if seed >= 0:
        RandomNumberGenerator.new().seed = seed
        # Use seeded RNG throughout instead of randi_range()

    initialize_level()
    place_entrance()
    generate_path(start, critical_path_length, "CP")
    generate_branches()
    # ...
```

Or use Godot's global seed:

```gdscript
if seed >= 0:
    randomize()  # only if seed < 0
    randi()      # warm up the RNG
```

Better yet, create a seeded RNG wrapper:

```gdscript
var _rng: RandomNumberGenerator

func _init() -> void:
    _rng = RandomNumberGenerator.new()

func set_seed(s: int) -> void:
    _rng.seed = s

func seeded_range(min_val: int, max_val: int) -> int:
    return _rng.randi_range(min_val, max_val)
```

Then replace all `randi_range()` calls with `seeded_range()`.

## Additional Features

- **Level sharing**: Expose the seed in the UI so players can copy/paste dungeon codes
- **Regenerate button**: Same seed + different random offset for "similar but different" variants
- **Minimap seed display**: Show current seed on the minimap screen

## Impact

- Players can share interesting dungeon layouts
- Debugging generation bugs becomes easier (reproducible steps)
- Enables features like "daily dungeon" or shared challenge modes
