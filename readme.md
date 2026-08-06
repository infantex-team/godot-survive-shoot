### Game Design

Improve the player level design.

### Prompt:

Feature: Configurable Experience, Leveling, and XP Collection

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

### Model GPT 5.5 - Result

 ERROR: res://Game/game_view.gd:106 - Parse Error: Could not find type "XPPickup" in the current scope.
 ERROR: res://Game/game_view.gd:106 - Parse Error: Cannot infer the type of "pickup" variable because the value doesn't have a set type.
 ERROR: modules/gdscript/gdscript_resource_format.cpp:46 - Failed to load script "res://Game/game_view.gd" with error "Parse error".
 ERROR: res://Game/game_view.gd:106 - Parse Error: Could not find type "XPPickup" in the current scope.
 ERROR: res://Game/game_view.gd:106 - Parse Error: Cannot infer the type of "pickup" variable because the value doesn't have a set type.
 ERROR: res://Game/Player/player.gd:17 - Parse Error: Could not find type "XPLevelConfig" in the current scope.
 ERROR: modules/gdscript/gdscript_resource_format.cpp:46 - Failed to load script "res://Game/Player/player.gd" with error "Parse error".
 ERROR: res://Game/Player/player.gd:17 - Parse Error: Could not find type "XPLevelConfig" in the current scope.
