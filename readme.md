## Game Design

Improve the player level design.

### Feature: Configurable Experience, Leveling, and XP Collection

This task adds an experience and leveling system to the existing top-down survival shooter loop. Enemies now drop collectible XP when defeated, and the player can level up automatically based on configurable XP thresholds.

### Implemented Result

- Each enemy has a configurable `xp_reward` value.
- When an enemy dies, it emits an XP drop event and spawns a burst of XP pickups at the enemy position.
- XP rewards are split across multiple pickups, and the total value of all pickups equals the defeated enemy's configured XP reward.
- XP pickup burst behavior is configurable through `xp_pickup_value` and `max_xp_pickups_per_drop` in `Game/game_view.gd`.
- XP pickups spread outward briefly before they can be collected.
- The player has a configurable `xp_magnet_radius`.
- The player scene includes a `Magnet` area that detects XP pickups entering the radius and starts collection.
- Collected XP pickups move toward the player, play a scale/fade collection effect, then add XP to the player.
- Each pickup prevents duplicate reward claims, so the same XP pickup cannot be collected more than once.
- Player level and current XP are tracked in `Game/Player/player.gd`.
- XP thresholds are stored in `Game/Player/default_xp_level_config.tres` using the `XPLevelConfig` resource.
- The leveling logic supports gaining multiple levels from a single XP gain.
- Remaining XP is preserved after each level up.
- The HUD now displays the player's current level and XP progress toward the next level.

### Key Files

- `Game/Enemy/enemy.gd`: configurable enemy XP reward and death-time XP drop signal.
- `Game/game_view.gd`: listens for enemy XP drops and spawns XP pickup bursts.
- `Game/Pickup/xp_pickup.gd`: XP pickup spread, magnet collection, collection effect, and reward claiming.
- `Game/Magnet/magnet.gd`: player magnet area used to detect nearby XP pickups.
- `Game/Player/player.gd`: player XP, level, magnet radius, and multi-level progression logic.
- `Game/Player/xp_level_config.gd`: resource type for level XP requirements.
- `Game/Player/default_xp_level_config.tres`: default XP requirement configuration.
- `Game/UI/hud.gd`: level and XP progress display.

### Gameplay Impact

Defeating enemies now creates a visible XP burst. After a short spread period, nearby XP pickups are attracted into the player by the magnet radius. Collected XP contributes to level progression, and the player can advance through one or more levels if enough XP is gained at once.
