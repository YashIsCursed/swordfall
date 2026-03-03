# MultiplayerMenu.gd - Multiplayer connection menu (Join/Host/LAN)
extends Control

enum MenuState {
	MAIN,
	JOIN,
	HOST,
	CONNECTING
}

@onready var main_panel: PanelContainer = $MainPanel
@onready var btn_join: Button = $MainPanel/MarginContainer/VBoxContainer/BtnJoin
@onready var btn_host: Button = $MainPanel/MarginContainer/VBoxContainer/BtnHost
@onready var btn_back: Button = $MainPanel/MarginContainer/VBoxContainer/BtnBack

# Join panel nodes - corrected paths
@onready var join_panel: PanelContainer = $JoinPanel if has_node("JoinPanel") else null
@onready var player_name_input: LineEdit = $JoinPanel/MarginContainer/VBoxContainer/PlayerNameInput if has_node("JoinPanel") else null
@onready var ip_input: LineEdit = $JoinPanel/MarginContainer/VBoxContainer/IPInput if has_node("JoinPanel") else null
@onready var port_input: LineEdit = $JoinPanel/MarginContainer/VBoxContainer/PortInput if has_node("JoinPanel") else null
@onready var btn_connect: Button = $JoinPanel/MarginContainer/VBoxContainer/ButtonsRow/BtnConnect if has_node("JoinPanel") else null
@onready var btn_join_back: Button = $JoinPanel/MarginContainer/VBoxContainer/ButtonsRow/BtnBack if has_node("JoinPanel") else null
@onready var server_list: VBoxContainer = $JoinPanel/MarginContainer/VBoxContainer/ScrollContainer/ServerList if has_node("JoinPanel") else null

# Host panel nodes - corrected paths
@onready var host_panel: PanelContainer = $HostPanel if has_node("HostPanel") else null
@onready var server_name_input: LineEdit = $HostPanel/MarginContainer/VBoxContainer/ServerNameInput if has_node("HostPanel") else null
@onready var host_port_input: LineEdit = $HostPanel/MarginContainer/VBoxContainer/PortInput if has_node("HostPanel") else null
@onready var btn_start_server: Button = $HostPanel/MarginContainer/VBoxContainer/ButtonsRow/BtnStartServer if has_node("HostPanel") else null
@onready var btn_host_back: Button = $HostPanel/MarginContainer/VBoxContainer/ButtonsRow/BtnBack if has_node("HostPanel") else null

@onready var status_label: Label = $StatusLabel if has_node("StatusLabel") else null

var current_state: MenuState = MenuState.MAIN
var _name_input_created: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Connect main buttons
	btn_join.pressed.connect(_show_join_panel)
	btn_host.pressed.connect(_show_host_panel)
	btn_back.pressed.connect(_on_back_to_main_menu)
	
	# Connect join panel buttons
	if btn_connect:
		btn_connect.pressed.connect(_on_connect_pressed)
	if btn_join_back:
		btn_join_back.pressed.connect(_show_main_panel)
	
	# Connect host panel buttons
	if btn_start_server:
		btn_start_server.pressed.connect(_on_start_server_pressed)
	if btn_host_back:
		btn_host_back.pressed.connect(_show_main_panel)
	
	# Connect multiplayer signals
	MultiplayerManager.connection_succeeded.connect(_on_connection_succeeded)
	MultiplayerManager.connection_failed.connect(_on_connection_failed)
	MultiplayerManager.server_discovered.connect(_on_server_discovered)
	
	_show_main_panel()

func _show_main_panel() -> void:
	current_state = MenuState.MAIN
	main_panel.visible = true
	if join_panel:
		join_panel.visible = false
	if host_panel:
		host_panel.visible = false
	
	MultiplayerManager.stop_lan_discovery()
	_set_status("")

func _show_join_panel() -> void:
	current_state = MenuState.JOIN
	main_panel.visible = false
	if join_panel:
		join_panel.visible = true
	if host_panel:
		host_panel.visible = false
	
	# Create name input if it doesn't exist
	_ensure_name_input_exists()
	
	# Prefill with saved player name
	if player_name_input:
		player_name_input.text = GameData.player_name
	
	# Start LAN discovery
	MultiplayerManager.start_lan_discovery()
	_refresh_server_list()
	_set_status("Searching for LAN servers...")

func _ensure_name_input_exists() -> void:
	if _name_input_created or not join_panel:
		return
	
	# Try to find the VBoxContainer in the join panel
	var vbox = join_panel.get_node_or_null("MarginContainer/VBoxContainer")
	if not vbox:
		return
	
	# Check if name input already exists
	if not player_name_input:
		# Create name label
		var name_label = Label.new()
		name_label.text = "Player Name:"
		vbox.add_child(name_label)
		vbox.move_child(name_label, 0) # Move to top
		
		# Create name input
		player_name_input = LineEdit.new()
		player_name_input.name = "PlayerNameInput"
		player_name_input.placeholder_text = "Enter your name..."
		player_name_input.text = GameData.player_name
		vbox.add_child(player_name_input)
		vbox.move_child(player_name_input, 1) # After label
		
		_name_input_created = true

func _show_host_panel() -> void:
	current_state = MenuState.HOST
	main_panel.visible = false
	if join_panel:
		join_panel.visible = false
	if host_panel:
		host_panel.visible = true
	
	if server_name_input:
		server_name_input.text = GameData.player_name + "'s Server"
	if host_port_input:
		host_port_input.text = str(MultiplayerManager.DEFAULT_PORT)
	
	_set_status("")

func _on_connect_pressed() -> void:
	var ip = "localhost"
	var port = MultiplayerManager.DEFAULT_PORT
	
	# Save player name before connecting
	if player_name_input and not player_name_input.text.strip_edges().is_empty():
		GameData.player_name = player_name_input.text.strip_edges()
		GameData.save_settings()
		print("MultiplayerMenu: Set player name to: ", GameData.player_name)
	
	if ip_input and not ip_input.text.strip_edges().is_empty():
		ip = ip_input.text.strip_edges()
	if port_input and not port_input.text.strip_edges().is_empty():
		port = int(port_input.text.strip_edges())
	
	_set_status("Connecting to " + ip + ":" + str(port) + "...")
	current_state = MenuState.CONNECTING
	
	var error = MultiplayerManager.create_Client(ip, port)
	if error != OK:
		_set_status("Failed to connect!")
		current_state = MenuState.JOIN

func _on_start_server_pressed() -> void:
	var server_name = "Swordfall Server"
	var port = MultiplayerManager.DEFAULT_PORT
	
	if server_name_input and not server_name_input.text.strip_edges().is_empty():
		server_name = server_name_input.text.strip_edges()
	if host_port_input and not host_port_input.text.strip_edges().is_empty():
		port = int(host_port_input.text.strip_edges())
	
	_set_status("Starting server...")
	var error = MultiplayerManager.create_Server(port, server_name)
	if error == OK:
		GameData.is_multiplayer = true
		GameData.is_host = true
		SceneManager.start_multiplayer_game()
	else:
		_set_status("Failed to start server on port " + str(port))

func _on_connection_succeeded() -> void:
	_set_status("Connected!")
	GameData.is_multiplayer = true
	GameData.is_host = false
	SceneManager.start_multiplayer_game()

func _on_connection_failed() -> void:
	_set_status("Connection failed!")
	current_state = MenuState.JOIN

func _on_server_discovered(server_info: Dictionary) -> void:
	_add_server_to_list(server_info)

func _refresh_server_list() -> void:
	if not server_list:
		return
	
	# Clear existing
	for child in server_list.get_children():
		child.queue_free()
	
	# Add discovered servers
	for server in MultiplayerManager.get_discovered_servers():
		_add_server_to_list(server)

func _add_server_to_list(server_info: Dictionary) -> void:
	if not server_list:
		return
	
	var item = HBoxContainer.new()
	item.add_theme_constant_override("separation", 10)
	
	var info_label = Label.new()
	info_label.text = server_info.get("name", "Unknown") + " - " + server_info.get("ip", "?") + ":" + str(server_info.get("port", 0))
	info_label.text += " (" + str(server_info.get("players", 0)) + "/" + str(server_info.get("max_players", 8)) + ")"
	info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var join_btn = Button.new()
	join_btn.text = "Join"
	join_btn.pressed.connect(_join_server.bind(server_info))
	
	item.add_child(info_label)
	item.add_child(join_btn)
	server_list.add_child(item)

func _join_server(server_info: Dictionary) -> void:
	var ip = server_info.get("ip", "localhost")
	var port = server_info.get("port", MultiplayerManager.DEFAULT_PORT)
	
	if ip_input:
		ip_input.text = ip
	if port_input:
		port_input.text = str(port)
	
	_on_connect_pressed()

func _on_back_to_main_menu() -> void:
	MultiplayerManager.stop_lan_discovery()
	SceneManager.go_to_main_menu()

func _set_status(text: String) -> void:
	if status_label:
		status_label.text = text
