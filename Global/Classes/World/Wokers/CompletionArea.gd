# CompletionArea.gd - Area that triggers level completion when player enters
extends Area3D
class_name CompletionArea

signal player_entered

@export var one_time_use: bool = true
var has_been_triggered: bool = false

func _init() -> void:
	monitorable = false
	monitoring = true
	collision_layer = 0
	collision_mask = 2 # Player layer

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is player and not has_been_triggered:
		if one_time_use:
			has_been_triggered = true
		player_entered.emit()
		print("Level completion triggered!")
