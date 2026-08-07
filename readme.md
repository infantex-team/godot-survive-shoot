# Survive Shoot

Survive Shoot is a top-down survival shooter built with Godot. The player controls a character in a small arena, dodging enemies while aiming with the mouse, shooting threats, and trying to survive for as long as possible.

## Gameplay

- Enemies spawn from the edges of the arena.
- Each enemy has its own health and can be defeated after taking enough bullet damage.
- Defeating enemies increases the score and grants coins.
- Enemies patrol, detect the player within their field of view, chase the player, investigate the last known position, and return to patrol if they lose sight.
- If an enemy reaches the player, it deals damage in timed attacks.
- Difficulty increases over time as the enemy spawn interval gradually becomes shorter.
- The arena limits the maximum number of enemies active at the same time.
- When the player's health reaches 0, the game ends and the final score is shown.

## Objective

Survive as long as possible, defeat as many enemies as you can, and aim for the highest score.

## Controls

| Action | Key / input |
| --- | --- |
| Move up | `W` or `Up` |
| Move down | `S` or `Down` |
| Move left | `A` or `Left` |
| Move right | `D` or `Right` |
| Aim | Move the mouse |
| Shoot | Left mouse button |
| Restart | Press the restart button on the Game Over screen |

## Combat System

- The player has `5` maximum health.
- The weapon has `30` bullets per magazine.
- Shooting has a short cooldown, so the player can hold the left mouse button to fire continuously.
- When the magazine is empty, the player automatically reloads after about `2` seconds.
- Bullets travel in the direction the player is facing and disappear when they hit a target, hit a wall, or expire.

## HUD

During gameplay, the HUD shows:

- `Health`: the player's current health.
- `Ammo`: current ammo and maximum ammo.
- `Coins`: coins earned by defeating enemies.
- `Score`: current score.
- `Enemies`: active enemy count and maximum enemy limit.

## How To Run

1. Open Godot.
2. Select `Import`.
3. Choose this project folder and select `project.godot`.
4. Open the project and press `Run Project`.

The main scene is already configured in `project.godot`, so the project can be run directly after import.

## Technology

- Engine: Godot 4.7
- Scripting language: GDScript
- Genre: Top-down survival shooter

---

# Trial Task 01 – Improve Player XP & Leveling System

## Trial Context

The base survival-shooter gameplay described above already existed before this trial.

GPT-5.5 was asked to modify the existing project and implement the XP and player-leveling system described below.

The purpose of the trial was to evaluate whether the AI agent could correctly implement and integrate the requested gameplay functionality in a **single attempt**.

## Initial State

- Initial branch: `master`
- Initial commit: `<INITIAL_COMMIT_SHA>`
- Engine: Godot 4.7

Both the GPT-5.5 attempt and the reference implementation were created from the same initial project state.

## AI Model and Test Conditions

- Model: GPT-5.5
- Attempts: 1
- Follow-up prompts: None
- Manual corrections after the AI attempt: None

The AI agent was given one task prompt and was not provided with any additional corrections or follow-up instructions after its initial implementation.

---

## Task

Improve the existing project by implementing a complete XP and player-leveling system with the following requirements:

1. Each enemy should have a configurable XP reward.

2. When an enemy dies, its XP reward should be distributed across multiple XP pickups.

3. The total XP value of all spawned pickups must exactly equal the XP reward of the defeated enemy.

4. XP pickups should briefly spread outward after spawning before becoming collectible.

5. The player should have a configurable magnet radius that attracts nearby XP pickups.

6. When attracted, XP pickups should move toward the player and provide appropriate collection feedback.

7. Collecting enough XP should automatically increase the player's level.

8. XP requirements for each level should be configurable through a reusable data resource rather than being hard-coded in gameplay logic.

9. A single XP collection must be able to trigger multiple level-ups if enough XP is received.

10. Remaining XP after a level-up must be preserved correctly.

11. The system must work correctly when multiple enemies die and multiple XP pickups are active simultaneously, without duplicated or lost XP rewards.

---

# GPT-5.5 Attempt Result

## Overall Result

**MATERIAL FAILURE**

GPT-5.5 implemented a substantial portion of the requested XP and leveling functionality in a single attempt.

The generated implementation included:

- Configurable XP rewards for enemies
- XP pickup spawning and XP distribution logic
- XP pickup spread and collection-delay logic
- Configurable player magnet radius
- XP pickup attraction toward the player
- A configurable `XPLevelConfig` resource
- Player XP and level progression
- Support for multiple level-ups from a single XP gain
- Preservation of remaining XP after leveling up

However, the resulting project failed to parse successfully because dependent scripts could not resolve the newly introduced `XPPickup` and `XPLevelConfig` types.

Observed errors included:

```text
Could not find type "XPPickup"
Could not find type "XPLevelConfig"
```

As a result, dependent gameplay scripts could not be loaded and the main gameplay scene could not run.

Because the project was left in a non-runnable state after the single AI attempt, the requested feature could not be functionally validated end-to-end.

We therefore classify the attempt as a **material failure**, even though a substantial portion of the intended gameplay logic was present in the generated code.

---

## Requirement Evaluation

| Requirement | GPT-5.5 Result | Notes |
| --- | --- | --- |
| Configurable enemy XP reward | Implemented in generated code | An exported XP reward value was added to enemies |
| Spawn multiple XP pickups | Implemented in generated code | XP pickup spawning logic was added when enemies die |
| Preserve total XP value | Implemented in generated code | Distribution logic attempts to preserve the total XP value, but runtime validation was not possible |
| Spread before collectible | Implemented in generated code | Spread and collectible-delay logic were added, but runtime validation was not possible |
| Configurable magnet radius | Implemented in generated code | A configurable player magnet radius was added |
| XP pickup attraction | Implemented in generated code | Pickups check their distance from the player and move toward the player when inside the magnet radius |
| Automatic player level-up | Implemented in generated code | XP progression and automatic level advancement logic were added |
| Configurable level requirements | Implemented in generated code | `XPLevelConfig` was introduced as a reusable `Resource` |
| Multiple level-ups from one XP gain | Implemented in generated code | Repeated level evaluation was implemented using a loop |
| Preserve remaining XP | Implemented in generated code | XP is reduced by each level requirement instead of being reset |
| Multiple enemies and pickups without duplicated or lost XP | Not verified | End-to-end runtime validation was not possible |
| Project parses and runs successfully | **FAIL** | Type-resolution / parse errors prevent the gameplay scene from running |

---

## Failure Analysis

GPT-5.5 demonstrated that it could understand and implement most of the individual requirements of the XP and leveling system.

The primary failure occurred during integration.

The AI introduced new types such as `XPPickup` and `XPLevelConfig`, but the final generated project contained type-resolution / parse errors when these types were referenced by dependent scripts.

Consequently, although much of the expected gameplay logic was generated, the complete project could not be executed.

This is considered a **material failure** because the expected outcome of the task was not simply to generate individual pieces of code, but to produce a working and integrated Godot implementation in a single attempt.

The AI-generated output therefore represents a substantial partial implementation, but not a successfully completed task.

---

## Implementation Observations

### Magnet Detection

The GPT-5.5 implementation uses per-frame distance checks from active XP pickups to determine whether each pickup is inside the player's magnet radius.

The reference implementation uses an `Area2D`-based magnet detection system instead.

This is recorded as an implementation difference rather than an AI failure because the task specification did not require a specific magnet-detection architecture or performance implementation.

### Magnet Visualization

The reference implementation includes a visual representation of the player's magnet area.

The GPT-5.5 implementation does not include this visualization.

This is **not considered a failure**, because visualizing the magnet radius was not explicitly required by the task specification.

---

## Final Assessment

GPT-5.5 successfully generated a substantial portion of the requested XP and player-leveling logic in a single attempt.

However, the generated changes did not produce a runnable and fully integrated Godot project because of type-resolution / parse failures involving the newly introduced types.

As a result, the gameplay feature could not be functionally validated end-to-end.

**Final Result: MATERIAL FAILURE**