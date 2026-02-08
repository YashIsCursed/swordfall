# Swordfall

A 3D Action RPG game with multiplayer support, developed in Godot 4.6.

## Features

- **3D Action RPG Gameplay** - First-person combat with sword attacks
- **Single Player Mode** - Create and manage game worlds with save/load functionality
- **Multiplayer Support** - Host LAN games or join others using ENet
- **Modular Level System** - Easy to add new levels, mobs, and content
- **Checkpoint System** - Auto-save progress at checkpoints
- **Combat System** - Hitbox/Hurtbox based damage with attack cooldowns

## Project Structure

```
swordfall-23/
├── Global/
│   ├── Classes/
│   │   ├── Entity/           # Base entity classes
│   │   │   ├── Entity.gd     # Base class for all entities
│   │   │   ├── EntityStats.gd # Stats resource (health, speed, etc.)
│   │   │   ├── Player/       # Player-specific code
│   │   │   └── Mobs/         # Mob AI and behavior
│   │   ├── World/            # World management
│   │   │   ├── World.gd      # World container
│   │   │   ├── Level.gd      # Level class
│   │   │   ├── Manager/      # WorldManager, LevelManager
│   │   │   └── Wokers/       # World workers (SpawnPoint, CheckPoint, etc.)
│   │   ├── MultiplayerManager/ # Networking (ENet)
│   │   ├── Hitbox.gd         # Damage dealing area
│   │   └── Hurtbox.gd        # Damage receiving area
│   └── Scripts/
│       ├── GameData.gd       # Autoload: Settings and world saves
│       └── SceneManager.gd   # Autoload: Scene transitions
├── Scenes/
│   ├── UI/                   # All UI scenes
│   │   ├── MainMenu.tscn     # Main menu (entry point)
│   │   ├── SinglePlayerMenu.tscn
│   │   ├── MultiplayerMenu.tscn
│   │   ├── SettingsMenu.tscn
│   │   ├── PauseMenu.tscn
│   │   └── HUD.tscn
│   └── Game/
│       └── GameWorld.tscn    # Main game scene
├── Levels/
│   ├── DemoLevel.gd          # Demo level script
│   └── DemoLevel.tscn        # Demo level scene
├── Assets/                   # 3D models and textures
├── player.tscn               # Player scene
├── mob1.tscn                 # Basic mob scene
└── project.godot             # Project configuration
```

## Game Flow

1. **Main Menu** → Select Single Player or Multiplayer
2. **Single Player** → Create/Load World → Start Game
3. **Multiplayer** → Host Server or Join by IP:Port
4. **In Game**:
   - WASD to move, Space to jump, Shift to sprint
   - Left Click to attack
   - ESC to pause (can open game to LAN from here)
   
## Controls

| Key | Action |
|-----|--------|
| W/A/S/D | Move |
| Space | Jump |
| Shift | Sprint |
| Left Click | Attack |
| E | Interact |
| ESC | Pause Menu |

## Adding New Content

### Adding a New Level

1. Create a new scene inheriting from `Level`
2. Add floor, walls, and platforms
3. Add a `SpawnPoint` marker
4. Add `CheckPoint` markers for save points
5. Add `MobArea` zones for enemies
6. Add a `CompletionArea` to trigger level completion
7. Register the level in WorldManager's `levels` array

### Adding a New Mob

1. Duplicate `mob1.tscn`
2. Modify the `E_Stats` resource for different health/damage/speed
3. Adjust the mesh and collision shapes
4. Configure AI settings (detection_range, attack_range, etc.)
5. Add to `MobArea.mob_scenes` array

## Autoloads

- **GameData** - Player settings, world saves, game state
- **SceneManager** - Scene loading and transitions
- **MultiplayerManager** - ENet server/client management

## Collision Layers

1. **World** - Static geometry
2. **Player** - Player character
3. **Hitbox** - Damage dealing areas
4. **Hurtbox** - Damage receiving areas
5. **Mob** - Enemy characters
6. **Interactable** - Interactive objects

## Requirements

- Godot 4.6+
- Forward+ renderer

## License

All rights reserved.
