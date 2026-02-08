# PauseMenu.gd - In-game pause menu
extends Control

signal resumed
signal quit_to_menu

@onready var btn_resume: Button = $PanelContainer/MarginContainer/VBoxContainer/BtnResume
@onready var btn_open_lan: Button = $PanelContainer/MarginContainer/VBoxContainer/BtnOpenLan if has_node("PanelContainer/MarginContainer/VBoxContainer/BtnOpenLan") else null
@onready var btn_settings: Button = $PanelContainer/MarginContainer/VBoxContainer/BtnSettings if has_node("PanelContainer/MarginContainer/VBoxContainer/BtnSettings") else null
@onready var btn_quit: Button = $PanelContainer/MarginContainer/VBoxContainer/BtnQuit
@onready var lan_info_label: Label = $PanelContainer/MarginContainer/VBoxContainer/LanInfoLabel if has_node("PanelContainer/MarginContainer/VBoxContainer/LanInfoLabel") else null
@onready var settings_panel: PanelContainer = $SettingsPanel if has_node("SettingsPanel") else null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	btn_resume.pressed.connect(_on_resume_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)
	
	if btn_open_lan:
		btn_open_lan.pressed.connect(_on_open_lan_pressed)
	if btn_settings:
		btn_settings.pressed.connect(_on_settings_pressed)
	
	_update_lan_button()
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and visible:
		_on_resume_pressed()

func show_pause_menu() -> void:
	_update_lan_button()
	show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func hide_pause_menu() -> void:
	if settings_panel:
		settings_panel.visible = false
	hide()

func _update_lan_button() -> void:
	if btn_open_lan:
		if GameData.is_multiplayer:
			if GameData.is_host:
				btn_open_lan.text = "Close LAN"
				if lan_info_label:
					lan_info_label.text = "Server running on port: " + str(MultiplayerManager.current_port)
					lan_info_label.visible = true
			else:
				btn_open_lan.visible = false
				if lan_info_label:
					lan_info_label.text = "Connected to multiplayer"
					lan_info_label.visible = true
		else:
			btn_open_lan.text = "Open to LAN"
			btn_open_lan.visible = true
			if lan_info_label:
				lan_info_label.visible = false

func _on_resume_pressed() -> void:
	hide_pause_menu()
	resumed.emit()

func _on_open_lan_pressed() -> void:
	if GameData.is_multiplayer and GameData.is_host:
		# Close LAN
		MultiplayerManager.disconnect_from_server()
		GameData.is_multiplayer = false
		GameData.is_host = false
	else:
		# Open to LAN with random port
		var port = randi_range(45000, 65000)
		var world_manager = get_tree().get_first_node_in_group("world_manager")
		if world_manager and world_manager.has_method("open_to_lan"):
			world_manager.open_to_lan(port)
	
	_update_lan_button()

func _on_settings_pressed() -> void:
	if settings_panel:
		settings_panel.visible = true

func _on_quit_pressed() -> void:
	# Save current progress
	GameData.save_current_world()
	
	# Disconnect multiplayer if connected
	if GameData.is_multiplayer:
		MultiplayerManager.disconnect_from_server()
	
	quit_to_menu.emit()
	SceneManager.go_to_main_menu()
