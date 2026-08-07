## Game Design

Improve the player level design.

### Feature: Configurable Experience, Leveling, and XP Collection

Implement an experience and leveling system for the player.

### Requirements:

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

## Result

Results with the Solution

- When an enemy dies, it spawns a configured amount of XP.
- xp_pickup objects are spawned with a visual spawn effect. (The AI model generated the logic, but the implementation contained syntax errors.)
- The player's magnet area is visually displayed and can be easily configured. (The AI model did not implement this.)
- XP pickup detection within the player's magnet area is optimized for performance. (The AI model instead continuously checked the distance from every xp_pickup object to the player.)
- A Godot Resource is used to configure XP requirements per level, making game balancing easier.
- The player correctly gains XP and levels up according to the configured level progression.
