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

## Initial State For Task 1: Level Design Improvement

The current game already includes the core survival shooter loop:

- The player can move, aim, shoot, take damage, reload automatically, collect coins, and die.
- Enemies spawn over time, patrol, detect the player, chase, attack, take damage, die, and grant score plus coins.
- The HUD displays health, ammo, coins, score, and active enemy count.
- Difficulty currently scales by reducing the enemy spawn interval over time.
- There is no experience, leveling, XP pickup, or level-based progression system yet.

### Feature: Configurable Experience, Leveling, and XP Collection

Task 1 should implement an experience and leveling system for the player.

Requirements:

- Each enemy has a configurable XP reward.
- When an enemy dies, its XP reward must burst into multiple smaller XP particles or pickups on the screen.
- The total value of all spawned XP pickups must equal the enemy's configured XP reward.
- XP pickups should spread outward briefly before becoming collectible.
- The player has a configurable magnet radius that attracts nearby XP pickups.
- Collected XP pickups should move toward the player and play a collection effect before being added to the player's XP.
- The player levels up automatically after reaching the required XP threshold.
- XP requirements for each level must be stored in configuration data.
- The system must support gaining enough XP to advance through multiple levels from a single collection.
- Remaining XP must be preserved after leveling up.
- The system must support multiple enemies and XP pickups without duplicated rewards or missed collections.
