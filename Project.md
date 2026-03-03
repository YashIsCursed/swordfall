# Swordfall

Discription: This Is a game Developed in godot 4.5, currently working in godot 4.6.

## Tech Stack

- Godot 4.6
- GDScript

## Game Details

- Name: Swordfall
- Genre: Action RPG
- Platform: PC
- Engine: Godot 4.6
- Language: GDScript
- Multiplayer: Yes
- World: Predefined
- Content: Modular
- Discription: Swordfall is a 3D Action RPG game with multiplayer support.

## Features

- 3D GAME
- Multiplayer Game using ENet
- Modular Structure
- Easy to add new content
- Easy to modify existing content
- Easy To add new Mobs, Models, etc.

## Future Plans

- Add Main Screen Ui (2D main Screen)
- Add Level System
- Add World System
- Add Interaction System
- Add System
- Add more content
- Add more features
- Add more Mobs, Models, etc.

## Everything About The Game

Swordfall is a 3D Action RPG game with multiplayer support. It features a predefined world, modular content, and a focus on easy content addition and modification. There Should Be both SinglePlayer and Multiplayer Mode that can be played in the same world, Player Starts A warld and They Can play the Game solo or Pause And click on 'Open To Lan' to Let other Player join With A generated port (Use ENet for Multiplayer).

### SinglePlayer Working

- Entity Class Root (Parent Class For All Entities like Player, Mob, etc.)
- Entity Class Have Basic Stats like Health, Name, Id, Weight (makes Changes in Jumpheight), MoveSpeed ,etc. (All Properties in E_Stats Class `EntityStats.gd` extends Resource) (the Entity Class in `Entity.gd` that Extends CharacterBody3D, Have Some Basic Functions like to add gravity, "'i want you to Modify it When Needed'")
- Entity Class Have Basic Actions like Move, Look, Attack, Block, Jump, Sprint, Interact
- Player Class (Child Class Of Entity and adds ability to move through the Inputs {W,A,S,D,Space}, Camera, and More,)
- Mob Class (Child Class Of Entity , I t has a rayCast that moves 5deg in a circle in front of it to detect the player, if the player is detected it will chase the player, if the player is not detected it will wander around, if the player is detected and in range it will attack the player, if the player is detected and not in range it will chase the player, if the player is not detected and not in range it will wander around, andmore props)
- some World Level Managing class are created as Event Listener Classes like ActionArea.gd (Area3D that detects player and calls a function that can be Modified accordingly), MobArea.gd (Area3D that detects player and spawn some Random Mobs around it when player is inside it), SpwnPoing.gd (Marker3D that spawns the player), Checkpoint,gd (Marker3D that saves the player's position). "'I wan tyou to add more stuff'"

### Multiplayer Working

- Everything From Singleplayer Remains Almost Same
- Using ENet for Multiplayer you use Ip:Port like Structure for Multiplayer (like `localhost:45456` or `127.0.0.1:45456`)

![Current Project Structure ](image.png)

## Things Todo

- Add all the Remaining Features
- Add all the Remaining Content
- Add all the Remaining Functions
- Add all the Remaining Classes
- Add all the Remaining Systems

- Add Level System
- Add World System
- Add Interaction System
- Add more content
- Add more features

> I want some change in the Structure of the Project , Make A folder Scenes that contains all the sub Folders for Mobs, player,World, etc.

> the game warks as you start the game you see game start menu with 4 vtns and logo on left (I will add the image just add a placeholder img)  [SinglePlayer , Multiplayer , Settings, Quit Game]

- In SinglePlayer you can play the game solo or Pause And click on 'Open To Lan' to Let other Player join With A generated port (Use ENet for Multiplayer).
- In Multiplayer you can join a game by entering the Ip:Port of the host (Use ENet for Multiplayer).
- In Settings you can change the settings of the game (Use ENet for Multiplayer).

How Game Works ->

1. Player when Click on Single Player (in UI 2D scene) they Get a Create /Load World Scene, in that scene they can create a new world or load a existing world, then they are sent to a new Window that Starts A new Game(3D Scene) in a 3d World the world is predefined(Levels) and has some SpwnPoints and some Checkpoints and some ActionAreas and some MobAreas and some SpwnPoings and some Checkpoint and more, but that's just First Level of the Game,When a player Dies or Quits the game they are sent to a checkpoint and when they are sent to a checkpoint they are sent to a new level, When Player Completes a level and Enters An CompleteArea then Next Level Is loaded and Old Is Removed From The root, Levels Are Predefined. I will Becreating Levels using The World System. so i want you to makea level Classthat Is used to create levels and World Class that is used List All The levels Inside it So that when Object of the World Class is created it will load all the levels and when Game is started the Player Will Either Spawn To it's last location(Checkpoint) orTo The LevelStart.
2. MobArea Works By spawning Mobs Listed In the MobsList that is in The MobArea Class Property(Array of Mobs).Mobs Do damage to the player with their Hitbox When Near and take Damage when Gets hit by players Hitbox to the hurbox. Mobs have a rayast That spins 5deg in a circle in front of it to detect the player, if the player is detected it will chase the player, if the player is not detected it will wander around, if the player is detected and in range it will attack the player, if the player is detected and not in range it will chase the player, if the player is not detected and not in range it will wander around.(that can me edited in props)
3. I decided to remove the Inventory and Just Give The Player Model A Sword and Add a hitbox to it. if it Hits a mob it will Kill and remove the mob, but Bosses are different, Bosses have health and they take a perticular damage and Die when >0 Health.
4. When Player clicks on the Multiplayer Button in the Main Menu they are sent to a new Window that allows them to enter a server using ip:port eg(120.0.0.0:45645), They can also See all the Lan Multiplayer Games, or They can create a new Multiplayer Server with Name and Port, others will see the server in the Lan Multiplayer Games list, when joining Multiplayer game a new Game(3D Scene) in a 3d World the world is predefined(Levels) and has some SpswnPoints and some Checkpoints and some ActionAreas and some MobAreas and some SpwnPoings and some Checkpoint and more, but that's just First Level of the Game,When a player Dies or Quits the game they are sent to a checkpoint, When Player Completes a level and Enters An CompleteArea then Next Level Is loaded and Old Is Removed From The root, Levels Are Predefined. I will Becreating Levels using The World System. so i want you to makea level Classthat Is used to create levels and World Class that is used List All The levels Inside it So that when Object of the World Class is created it will load all the levels and when Game is started the Player WillEyther Spawn To it's last location(Checkpoint) orTo The LevelStart.
5. Settings Have The Player NAME and Other Details like Mouse Sensitivity, FOV, etc.

# WHAT YOU WILL BE DOING

You Will Write all the code for the game,
that includes the Working for all the things Required for the game,
delete The Unnecessary files.
