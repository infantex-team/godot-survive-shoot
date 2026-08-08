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

| Action     | Key / input                                      |
| ---------- | ------------------------------------------------ |
| Move up    | `W` or `Up`                                      |
| Move down  | `S` or `Down`                                    |
| Move left  | `A` or `Left`                                    |
| Move right | `D` or `Right`                                   |
| Aim        | Move the mouse                                   |
| Shoot      | Left mouse button                                |
| Restart    | Press the restart button on the Game Over screen |

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

## Initial State

This `master` branch represents the **initial project state before Trial Task 01**.

The XP and player-leveling system is not implemented in this branch.

Trial Task 01 branches:

| Purpose                     | Branch                               |
| --------------------------- | ------------------------------------ |
| Initial State               | `master`                             |
| GPT-5.5 Attempt             | `task_1_improve_player_level_gpt5.5` |
| Infantex Reference Solution | `task_1_improve_player_level`        |

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
