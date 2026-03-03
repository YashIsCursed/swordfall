# MobsConfig.gd - Configuration for all game mobs/enemies
# This file defines all mob types and their metadata
extends RefCounted
class_name MobsConfig

# All mob scenes with their paths
const MOB_SCENES: Dictionary = {
	"goblin": "res://Scenes/Entities/Mobs/Goblin.tscn",
	"skeleton": "res://Scenes/Entities/Mobs/Skeleton.tscn",
	"orc": "res://Scenes/Entities/Mobs/Orc.tscn",
	"spider": "res://Scenes/Entities/Mobs/Spider.tscn",
	"wraith": "res://Scenes/Entities/Mobs/Wraith.tscn",
	"golem": "res://Scenes/Entities/Mobs/Golem.tscn",
	"demon_lord": "res://Scenes/Entities/Mobs/DemonLord.tscn",
}

# Detailed mob information for documentation/UI
const MOB_INFO: Dictionary = {
	"goblin": {
		"name": "Goblin Scout",
		"description": "Fast and agile, but weak. Attacks quickly in packs.",
		"health": 8,
		"damage": 2,
		"speed": "Fast",
		"difficulty": "Easy",
		"icon": "🧟",
		"found_in": ["Forest Entrance"],
	},
	"skeleton": {
		"name": "Skeleton Warrior",
		"description": "Undead warrior with balanced stats. A common threat.",
		"health": 12,
		"damage": 3,
		"speed": "Medium",
		"difficulty": "Medium",
		"icon": "💀",
		"found_in": ["Cave Descent", "Ancient Ruins"],
	},
	"orc": {
		"name": "Orc Brute",
		"description": "Slow but tanky. Hits hard when it catches you.",
		"health": 20,
		"damage": 5,
		"speed": "Slow",
		"difficulty": "Medium-Hard",
		"icon": "👹",
		"found_in": ["Ancient Ruins", "Demon Throne"],
	},
	"spider": {
		"name": "Cave Spider",
		"description": "Very fast with rapid attacks. Fragile but elusive.",
		"health": 6,
		"damage": 2,
		"speed": "Very Fast",
		"difficulty": "Easy-Medium",
		"icon": "🕷️",
		"found_in": ["Cave Descent"],
	},
	"wraith": {
		"name": "Shadow Wraith",
		"description": "Ethereal ghost with long detection range. Floats eerily.",
		"health": 10,
		"damage": 4,
		"speed": "Medium",
		"difficulty": "Medium",
		"icon": "👻",
		"found_in": ["Ancient Ruins", "Frozen Citadel"],
	},
	"golem": {
		"name": "Stone Golem",
		"description": "Extremely tanky guardian. Very slow but devastating attacks.",
		"health": 35,
		"damage": 8,
		"speed": "Very Slow",
		"difficulty": "Hard",
		"icon": "🗿",
		"found_in": ["Frozen Citadel"],
	},
	"demon_lord": {
		"name": "Demon Lord",
		"description": "THE FINAL BOSS. Massive health pool and deadly attacks.",
		"health": 100,
		"damage": 12,
		"speed": "Medium",
		"difficulty": "BOSS",
		"icon": "😈",
		"found_in": ["Demon Throne"],
		"is_boss": true,
	},
}

# Get mob scene path by key
static func get_mob_path(mob_key: String) -> String:
	if MOB_SCENES.has(mob_key):
		return MOB_SCENES[mob_key]
	return ""

# Get mob info by key
static func get_mob_info(mob_key: String) -> Dictionary:
	if MOB_INFO.has(mob_key):
		return MOB_INFO[mob_key]
	return {}

# Load a mob scene by key
static func load_mob(mob_key: String) -> PackedScene:
	var path = get_mob_path(mob_key)
	if path.is_empty():
		push_error("Invalid mob key: " + mob_key)
		return null
	return load(path)

# Get all mob keys
static func get_all_mob_keys() -> Array:
	return MOB_SCENES.keys()

# Get mobs by difficulty
static func get_mobs_by_difficulty(difficulty: String) -> Array:
	var result: Array = []
	for key in MOB_INFO.keys():
		if MOB_INFO[key].get("difficulty", "") == difficulty:
			result.append(key)
	return result
