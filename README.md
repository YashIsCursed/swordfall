# Swordfall

A 3D Action RPG game with multiplayer support, developed in Godot 4.6.

## Features

- **3D Action RPG Gameplay** - First-person combat with sword attacks
- **5 Unique Levels** - Progressive difficulty from Forest to Boss Arena
- **7 Enemy Types** - From simple goblins to the Demon Lord boss
- **Single Player Mode** - Create and manage game worlds with save/load functionality
- **Multiplayer Support** - Host LAN games or join others using ENet
- **Loading Screen** - Visual progress indicators with freeze detection
- **Checkpoint System** - Auto-save progress at checkpoints
- **Combat System** - Hitbox/Hurtbox based damage with attack cooldowns

---

## 🗺️ Levels

| # | Level | Theme | Difficulty | Enemies |
|---|-------|-------|------------|---------|
| 0 | **Forest Entrance** 🌲 | Bright outdoor forest | Easy | Goblin Scout |
| 1 | **Cave Descent** 🕳️ | Dark underground cave | Medium | Cave Spider, Skeleton |
| 2 | **Ancient Ruins** 🏛️ | Crumbling stone ruins | Medium-Hard | Orc, Wraith, Skeleton |
| 3 | **Frozen Citadel** ❄️ | Icy fortress | Hard | Stone Golem, Wraith |
| 4 | **Demon Throne** 👹 | Dark boss arena | BOSS | Orc, **Demon Lord** |

---

## 👹 Enemies

| Enemy | Health | Damage | Speed | Behavior |
|-------|--------|--------|-------|----------|
| **Goblin Scout** 🧟 | 8 | 2 | Fast | Quick attacks, weak |
| **Cave Spider** 🕷️ | 6 | 2 | Very Fast | Rapid attacks, fragile |
| **Skeleton Warrior** 💀 | 12 | 3 | Medium | Balanced fighter |
| **Orc Brute** 👹 | 20 | 5 | Slow | Tanky, heavy hits |
| **Shadow Wraith** 👻 | 10 | 4 | Medium | Long detection, ethereal |
| **Stone Golem** 🗿 | 35 | 8 | Very Slow | Mini-boss, devastating |
| **Demon Lord** 😈 | **100** | **12** | Medium | **FINAL BOSS** |

---

## ⏳ Loading System

The game features a professional loading screen with:
- **Progress Bar** - Visual loading progress (0-100%)
- **Status Messages** - Dynamic phase descriptions
- **Rotating Tips** - Gameplay hints during loading
- **Elapsed Time** - Shows time since loading started
- **Freeze Detection** - Warning if loading takes >10 seconds
- **Error Handling** - Clear error messages if loading fails

This ensures users always know the game is loading (not crashed).

---

## Project Structure

```
swordfall-23/
├── Global/
│   ├── Classes/
│   │   ├── Entity/                    # Base entity classes
│   │   │   ├── Entity.gd              # Base class for all entities
│   │   │   ├── EntityStats.gd         # Stats resource (health, speed, etc.)
│   │   │   ├── Player/                # Player-specific code
│   │   │   └── Mobs/                  # Mob AI and behavior
│   │   │       ├── Mobs.gd            # Mob AI state machine
│   │   │       └── MobsConfig.gd      # Mob registry & metadata
│   │   ├── World/                     # World management
│   │   │   ├── Level.gd               # Level class
│   │   │   ├── LevelsConfig.gd        # Level registry & metadata
│   │   │   ├── Manager/               # WorldManager, LevelManager
│   │   │   └── Wokers/                # SpawnPoint, CheckPoint, etc.
│   │   ├── MultiplayerManager/        # Networking (ENet)
│   │   ├── Hitbox.gd                  # Damage dealing area
│   │   └── Hurtbox.gd                 # Damage receiving area
│   └── Scripts/
│       ├── GameData.gd                # Autoload: Settings and world saves
│       └── SceneManager.gd            # Autoload: Scene transitions + loading
├── Scenes/
│   ├── UI/                            # All UI scenes
│   │   ├── MainMenu.tscn
│   │   ├── SinglePlayerMenu.tscn
│   │   ├── MultiplayerMenu.tscn
│   │   ├── SettingsMenu.tscn
│   │   ├── PauseMenu.tscn
│   │   ├── HUD.tscn
│   │   ├── LoadingScreen.tscn         # NEW: Loading screen
│   │   └── LoadingScreen.gd
│   ├── Game/
│   │   └── GameWorld.tscn             # Main game scene
│   └── Entities/
│       └── Mobs/                      # All mob scenes
│           ├── Goblin.tscn
│           ├── Skeleton.tscn
│           ├── Orc.tscn
│           ├── Spider.tscn
│           ├── Wraith.tscn
│           ├── Golem.tscn
│           └── DemonLord.tscn         # BOSS
├── Levels/                            # All level scenes
│   ├── Level_ForestEntrance.tscn
│   ├── Level_CaveDescent.tscn
│   ├── Level_AncientRuins.tscn
│   ├── Level_FrozenCitadel.tscn
│   └── Level_DemonThrone.tscn         # BOSS LEVEL
├── Assets/                            # 3D models and textures
├── player.tscn                        # Player scene
└── project.godot                      # Project configuration
```

---

## Game Flow

1. **Main Menu** → Select Single Player or Multiplayer
2. **Single Player** → Create/Load World → Start Game
3. **Multiplayer** → Host Server or Join by IP:Port
4. **Loading Screen** → Shows progress while world loads
5. **In Game**:
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

---

## Adding New Content

### Adding a New Level

1. Create `.gd` file extending `Level` in `Levels/`
2. Create `.tscn` scene with floor, walls, SpawnPoint, CheckPoint, MobArea, CompletionArea
3. Register in `LevelsConfig.gd`

### Adding a New Mob

1. Create `.tscn` in `Scenes/Entities/Mobs/` using existing mob as template
2. Configure E_Stats (health, speed, damage) and AI settings
3. Register in `MobsConfig.gd`
4. Add to level's MobArea

---

## Requirements

- Godot 4.6+
- Forward+ renderer

## License

All rights reserved.

