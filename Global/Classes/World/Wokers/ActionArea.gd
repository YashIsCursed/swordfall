# ActionArea.gd - Base area class for triggering actions when player enters/exits
extends Area3D
class_name ActionArea

signal on_player_enter(player_ref: player)
signal on_player_exit(player_ref: player)
signal on_any_body_enter(body: Node3D)
signal on_any_body_exit(body: Node3D)

@export_category("Action Area Settings")
@export var one_shot: bool = false
@export var detect_player_only: bool = true

var has_triggered: bool = false
var players_inside: Array[player] = []

func _init() -> void:
	monitorable = false
	monitoring = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if one_shot and has_triggered:
		return
	
	on_any_body_enter.emit(body)
	
	if body is player:
		players_inside.append(body)
		has_triggered = true
		on_player_enter.emit(body)
		_on_player_enter_action(body)
	elif not detect_player_only:
		_on_enter_action(body)

func _on_body_exited(body: Node3D) -> void:
	on_any_body_exit.emit(body)
	
	if body is player:
		players_inside.erase(body)
		on_player_exit.emit(body)
		_on_player_exit_action(body)
	elif not detect_player_only:
		_on_exit_action(body)

# Override these in child classes
func _on_player_enter_action(player_ref: player) -> void:
	pass

func _on_player_exit_action(player_ref: player) -> void:
	pass

func _on_enter_action(body: Node3D) -> void:
	pass

func _on_exit_action(body: Node3D) -> void:
	pass

func reset() -> void:
	has_triggered = false
	players_inside.clear()

func is_player_inside() -> bool:
	return not players_inside.is_empty()

func get_players_inside() -> Array[player]:
	return players_inside
