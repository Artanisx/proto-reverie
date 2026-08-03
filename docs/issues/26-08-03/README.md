# Procedural Level Generation - Issues

Issues generated from codebase analysis, sorted by priority.

## Critical Bugs
- [#01](01-calculate_cp_length-broken.md) - `calculate_cp_length()` crashes on room identifiers
- [#02](02-branch_length-inconsistent-parsing.md) - `calculate_branch_length()` parsing is inconsistent

## High Priority Refactors
- [#03](03-adjacency-selection-if-elif-chain.md) - Replace 50-line if/elif chain with bitmask lookup
- [#04](04-check_neighboor-state-machine.md) - Replace 160-line check_neighboor() state machine with data-driven lookup

## Medium Priority Refactors
- [#05](05-fragile-string-identifiers.md) - Replace string-based room identifiers with structured data
- [#06](06-no-generation-fallback.md) - No retry mechanism when generation fails
- [#07](07-couple-path-gen-with-branch-tracking.md) - `generate_path()` couples path generation with branch tracking

## Low Priority / Cosmetic
- [#08](08-duplicate-debug-functions.md) - Consolidate 7 nearly-identical debug print functions

## Feature Requests
- [#09](09-add-seeded-rng.md) - Add deterministic seeding for reproducible levels
- [#10](10-add-connectivity-validation.md) - Add post-generation connectivity validation
