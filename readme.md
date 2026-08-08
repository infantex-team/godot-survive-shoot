# Trial Task 01 – GPT-5.5 Attempt

## Game Design

Improve the player level design.

## Prompt

**Feature: Configurable Experience, Leveling, and XP Collection**

Implement an experience and leveling system for the player.

Requirements:

- Each enemy has a configurable XP reward.
- When an enemy dies, its XP reward must burst into multiple smaller XP particles or pickups on the screen.
- The total value of all spawned XP pickups must equal the enemy’s configured XP reward.
- XP pickups should spread outward briefly before becoming collectible.
- The player has a configurable magnet radius that attracts nearby XP pickups.
- Collected XP pickups should move toward the player and play a collection effect before being added to the player’s XP.
- The player levels up automatically after reaching the required XP threshold.
- XP requirements for each level must be stored in configuration data.
- Support gaining enough XP to advance through multiple levels from a single collection.
- Preserve any remaining XP after leveling up.
- The system must support multiple enemies and XP pickups without duplicated rewards or missed collections.

## Model

- Model: GPT-5.5
- Attempts: 1
- Follow-up prompts: None
- Manual fixes after generation: None

## GPT-5.5 Generated Result

GPT-5.5 generated a substantial portion of the requested XP and leveling system, including:

- Configurable XP rewards for enemies
- XP pickup spawning and XP distribution logic
- XP pickup spread and collectible delay
- Configurable player magnet radius
- XP pickup attraction and collection behavior
- `XPPickup`
- `XPLevelConfig`
- Player XP and level progression
- Multiple level-up handling
- Remaining XP preservation

For example, GPT-5.5 generated `XPPickup` as a dedicated `Area2D` class with spread duration, collectible delay, magnet movement, collection effect, and reward-claim protection.

## Result

The generated project failed to run because Godot reported parse/type-resolution errors.

Observed errors:

ERROR: res://Game/game_view.gd:106
Parse Error: Could not find type "XPPickup" in the current scope.

ERROR: res://Game/game_view.gd:106
Parse Error: Cannot infer the type of "pickup" variable because the value doesn't have a set type.

ERROR: res://Game/Player/player.gd:17
Parse Error: Could not find type "XPLevelConfig" in the current scope.

ERROR: Failed to load dependent scripts due to parse errors.

---

## XP Pickup Distance Detection Assessment

### Overview
Distance detection between `XPPickup` and the player is handled individually by each pickup node inside its `_process(delta)` loop using `global_position.distance_to(_player.global_position)`. Once collectible, each pickup checks its distance against the player's `xp_magnet_radius` to trigger attraction toward the player, and `collection_distance` to initiate reward collection.

### Pros
- **Simplicity**: Straightforward, self-contained logic inside `XPPickup` that is easy to read and maintain.
- **Frame-Accurate Responsiveness**: Per-frame distance polling allows pickups to react immediately as the player moves or modifies their magnet radius.

### Cons
- **Performance Overhead**: Running `_process` polling on every pickup scales poorly ($O(N)$) with large numbers of concurrent XP drops on screen.
- **Unnecessary Distance Calculations**: `distance_to()` performs costly square root operations every frame, including for pickups far outside the magnet radius.

