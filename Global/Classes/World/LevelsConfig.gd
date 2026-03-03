# LevelsConfig.gd - Configuration for all game levels in sequence
# This file defines the order and metadata for all levels in the game
extends RefCounted
class_name LevelsConfig

# All level scenes in sequential order
const LEVEL_SCENES: Array[String] = [
	"res://Levels/Level_ForestEntrance.tscn", # Level 0: Forest Entrance (Tutorial)
	"res://Levels/Level_CaveDescent.tscn", # Level 1: Cave Descent
	"res://Levels/Level_AncientRuins.tscn", # Level 2: Ancient Ruins
	"res://Levels/Level_FrozenCitadel.tscn", # Level 3: Frozen Citadel
	"res://Levels/Level_DemonThrone.tscn", # Level 4: Demon Throne (Boss)
]

# Level metadata for UI display
const LEVEL_INFO: Array[Dictionary] = [
	{
		"name": "Forest Entrance",
		"description": "A peaceful forest that marks the beginning of your journey. Beware of goblin scouts!",
		"difficulty": "Easy",
		"enemies": ["Goblin Scout"],
		"icon": "🌲"
	},
	{
		"name": "Cave Descent",
		"description": "Dark underground caves filled with spiders and ancient skeletons.",
		"difficulty": "Medium",
		"enemies": ["Cave Spider", "Skeleton Warrior"],
		"icon": "🕳️"
	},
	{
		"name": "Ancient Ruins",
		"description": "Crumbling ruins of a forgotten civilization. Orcs and wraiths roam these halls.",
		"difficulty": "Medium-Hard",
		"enemies": ["Orc Brute", "Shadow Wraith", "Skeleton Warrior"],
		"icon": "🏛️"
	},
	{
		"name": "Frozen Citadel",
		"description": "An icy fortress high in the mountains. Stone golems guard its secrets.",
		"difficulty": "Hard",
		"enemies": ["Stone Golem", "Shadow Wraith"],
		"icon": "❄️"
	},
	{
		"name": "Demon Throne",
		"description": "The final battle awaits. Face the Demon Lord in his dark throne room!",
		"difficulty": "Boss",
		"enemies": ["Orc Brute", "Demon Lord (BOSS)"],
		"icon": "👹"
	},
]

# Get level count
static func get_level_count() -> int:
	return LEVEL_SCENES.size()

# Get level scene path by index
static func get_level_path(index: int) -> String:
	if index >= 0 and index < LEVEL_SCENES.size():
		return LEVEL_SCENES[index]
	return ""

# Get level info by index
static func get_level_info(index: int) -> Dictionary:
	if index >= 0 and index < LEVEL_INFO.size():
		return LEVEL_INFO[index]
	return {}

# Load a level scene by index
static func load_level(index: int) -> PackedScene:
	var path = get_level_path(index)
	if path.is_empty():
		push_error("Invalid level index: " + str(index))
		return null
	return load(path)

# Get all levels as PackedScene array (for WorldManager)
static func get_all_level_scenes() -> Array[PackedScene]:
	var scenes: Array[PackedScene] = []
	for path in LEVEL_SCENES:
		var scene = load(path) as PackedScene
		if scene:
			scenes.append(scene)
	return scenes
