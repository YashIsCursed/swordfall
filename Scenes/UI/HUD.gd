# HUD.gd - In-game heads-up display with player list
extends Control

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/TopRow/HealthBar if has_node("MarginContainer/VBoxContainer/TopRow/HealthBar") else null
@onready var health_label: Label = $MarginContainer/VBoxContainer/TopRow/HealthLabel if has_node("MarginContainer/VBoxContainer/TopRow/HealthLabel") else null
@onready var level_label: Label = $MarginContainer/VBoxContainer/TopRow/LevelLabel if has_node("MarginContainer/VBoxContainer/TopRow/LevelLabel") else null
@onready var crosshair: Label = $Crosshair if has_node("Crosshair") else null
@onready var interaction_prompt: Label = $InteractionPrompt if has_node("InteractionPrompt") else null
@onready var death_overlay: ColorRect = $DeathOverlay if has_node("DeathOverlay") else null
@onready var respawn_label: Label = $DeathOverlay/RespawnLabel if has_node("DeathOverlay/RespawnLabel") else null
@onready var player_list_panel: PanelContainer = $PlayerListPanel if has_node("PlayerListPanel") else null
@onready var player_list_container: VBoxContainer = $PlayerListPanel/MarginContainer/VBoxContainer/PlayerList if has_node("PlayerListPanel") else null

var player_ref: player = null
var _player_entries: Dictionary = {} # peer_id -> Label

func _ready() -> void:
	if death_overlay:
		death_overlay.visible = false
	if interaction_prompt:
		interaction_prompt.visible = false
	
	# Create player list panel if it doesn't exist and we're in multiplayer
	if GameData.is_multiplayer and not player_list_panel:
		_create_player_list_panel()
	elif player_list_panel:
		player_list_panel.visible = GameData.is_multiplayer
	
	# Connect to multiplayer signals for player list updates
	if GameData.is_multiplayer:
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _create_player_list_panel() -> void:
	player_list_panel = PanelContainer.new()
	player_list_panel.name = "PlayerListPanel"
	
	# Position on mid-right of screen - small fixed size panel
	player_list_panel.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	player_list_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	player_list_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	player_list_panel.custom_minimum_size = Vector2(180, 0) # Min width, auto height
	player_list_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# Position offsets from right edge
	player_list_panel.position = Vector2(-200, 0) # Will be adjusted by anchor
	player_list_panel.offset_left = -190
	player_list_panel.offset_right = -10
	player_list_panel.offset_top = -80
	player_list_panel.offset_bottom = 80
	
	# Dark semi-transparent background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	player_list_panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	player_list_panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "👥 Players"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	vbox.add_child(title)
	
	var separator = HSeparator.new()
	separator.add_theme_constant_override("separation", 2)
	vbox.add_child(separator)
	
	player_list_container = VBoxContainer.new()
	player_list_container.name = "PlayerList"
	player_list_container.add_theme_constant_override("separation", 2)
	vbox.add_child(player_list_container)
	
	add_child(player_list_panel)

func setup_player(p: player) -> void:
	player_ref = p
	
	if player_ref and player_ref.props:
		# Connect to health updates
		player_ref.props.update_health.connect(_on_health_updated)
		player_ref.on_death.connect(_on_player_death)
		
		# Initial update
		_update_health_display(player_ref.props.Health, player_ref.props.MaxHealth)
	
	# Update player list
	if GameData.is_multiplayer:
		_refresh_player_list()

func _on_health_updated(current: float, maximum: float) -> void:
	_update_health_display(current, maximum)

func _update_health_display(current: float, maximum: float) -> void:
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current
	
	if health_label:
		health_label.text = str(int(current)) + " / " + str(int(maximum))

func update_level(level_name: String, level_index: int) -> void:
	if level_label:
		level_label.text = "Level " + str(level_index + 1) + ": " + level_name
		print("HUD: Level updated to - ", level_label.text)

func show_interaction_prompt(text: String) -> void:
	if interaction_prompt:
		interaction_prompt.text = "[E] " + text
		interaction_prompt.visible = true

func hide_interaction_prompt() -> void:
	if interaction_prompt:
		interaction_prompt.visible = false

func _on_player_death() -> void:
	show_death_screen()

func show_death_screen() -> void:
	if death_overlay:
		death_overlay.visible = true
		death_overlay.modulate.a = 0
		
		var tween = create_tween()
		tween.tween_property(death_overlay, "modulate:a", 0.8, 0.5)
		
		if respawn_label:
			respawn_label.text = "You Died\nRespawning..."

func hide_death_screen() -> void:
	if death_overlay:
		var tween = create_tween()
		tween.tween_property(death_overlay, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): death_overlay.visible = false)

# ========== Player List Management ==========

func _on_peer_connected(id: int) -> void:
	print("HUD: Peer connected - ", id)
	await get_tree().create_timer(0.5).timeout # Wait for player data to sync
	_refresh_player_list()

func _on_peer_disconnected(id: int) -> void:
	print("HUD: Peer disconnected - ", id)
	_refresh_player_list()

func _refresh_player_list() -> void:
	if not player_list_container:
		return
	
	# Clear existing entries
	for child in player_list_container.get_children():
		child.queue_free()
	_player_entries.clear()
	
	# Add all players
	var world_manager = get_tree().get_first_node_in_group("world_manager")
	if world_manager and world_manager.has_method("get"):
		var players = world_manager.get("players") if "players" in world_manager else {}
		for peer_id in players:
			var p = players[peer_id]
			_add_player_entry(peer_id, p)
	else:
		# Fallback: add local player
		if player_ref and player_ref.props:
			_add_player_entry(1, player_ref)

func _add_player_entry(peer_id: int, p: Node) -> void:
	if not player_list_container:
		return
	
	var entry = HBoxContainer.new()
	entry.add_theme_constant_override("separation", 8)
	
	# Player indicator (host/local marker)
	var indicator = Label.new()
	if peer_id == 1:
		indicator.text = "👑" # Host
	elif player_ref and p == player_ref:
		indicator.text = "➤" # You
	else:
		indicator.text = "•"
	indicator.add_theme_font_size_override("font_size", 14)
	
	# Player name
	var name_label = Label.new()
	if p and p.has_method("get") and "props" in p and p.props:
		name_label.text = p.props.Name
	else:
		name_label.text = "Player " + str(peer_id)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 14)
	
	# Level indicator (show which level they're on)
	var level_indicator = Label.new()
	level_indicator.text = "L" + str(GameData.current_level_index + 1)
	level_indicator.add_theme_font_size_override("font_size", 12)
	level_indicator.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	
	entry.add_child(indicator)
	entry.add_child(name_label)
	entry.add_child(level_indicator)
	
	player_list_container.add_child(entry)
	_player_entries[peer_id] = entry

func add_player_to_list(peer_id: int, player_name: String, level_index: int) -> void:
	if not player_list_container:
		return
	
	var entry = HBoxContainer.new()
	
	var indicator = Label.new()
	indicator.text = "👑" if peer_id == 1 else "•"
	
	var name_label = Label.new()
	name_label.text = player_name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var level_label_entry = Label.new()
	level_label_entry.text = "L" + str(level_index + 1)
	
	entry.add_child(indicator)
	entry.add_child(name_label)
	entry.add_child(level_label_entry)
	
	player_list_container.add_child(entry)
	_player_entries[peer_id] = entry

func remove_player_from_list(peer_id: int) -> void:
	if _player_entries.has(peer_id):
		_player_entries[peer_id].queue_free()
		_player_entries.erase(peer_id)
