# Main.gd - Entry point scene that immediately transitions to MainMenu
extends Node

func _ready() -> void:
	# This is a fallback scene - immediately redirect to MainMenu
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
