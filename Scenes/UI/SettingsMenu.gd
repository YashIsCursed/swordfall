# SettingsMenu.gd - Settings menu for player preferences
extends Control

@onready var player_name_input: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/PlayerSection/NameInput
@onready var sensitivity_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/ControlsSection/SensitivitySlider
@onready var sensitivity_value: Label = $PanelContainer/MarginContainer/VBoxContainer/ControlsSection/SensitivityValue
@onready var fov_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/GraphicsSection/FOVSlider
@onready var fov_value: Label = $PanelContainer/MarginContainer/VBoxContainer/GraphicsSection/FOVValue
@onready var master_volume_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/AudioSection/MasterVolumeSlider if has_node("PanelContainer/MarginContainer/VBoxContainer/AudioSection/MasterVolumeSlider") else null
@onready var master_volume_value: Label = $PanelContainer/MarginContainer/VBoxContainer/AudioSection/MasterVolumeValue if has_node("PanelContainer/MarginContainer/VBoxContainer/AudioSection/MasterVolumeValue") else null
@onready var btn_save: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/BtnSave
@onready var btn_back: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/BtnBack

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Load current settings
	_load_settings()
	
	# Connect signals
	btn_save.pressed.connect(_on_save_pressed)
	btn_back.pressed.connect(_on_back_pressed)
	
	if sensitivity_slider:
		sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	if fov_slider:
		fov_slider.value_changed.connect(_on_fov_changed)
	if master_volume_slider:
		master_volume_slider.value_changed.connect(_on_master_volume_changed)

func _load_settings() -> void:
	if player_name_input:
		player_name_input.text = GameData.player_name
	
	if sensitivity_slider:
		sensitivity_slider.min_value = 0.001
		sensitivity_slider.max_value = 0.02
		sensitivity_slider.step = 0.001
		sensitivity_slider.value = GameData.mouse_sensitivity
		_update_sensitivity_label(GameData.mouse_sensitivity)
	
	if fov_slider:
		fov_slider.min_value = 50
		fov_slider.max_value = 120
		fov_slider.step = 5
		fov_slider.value = GameData.field_of_view
		_update_fov_label(GameData.field_of_view)
	
	if master_volume_slider:
		master_volume_slider.min_value = 0
		master_volume_slider.max_value = 1
		master_volume_slider.step = 0.1
		master_volume_slider.value = GameData.master_volume
		_update_master_volume_label(GameData.master_volume)

func _on_sensitivity_changed(value: float) -> void:
	_update_sensitivity_label(value)

func _update_sensitivity_label(value: float) -> void:
	if sensitivity_value:
		sensitivity_value.text = str(snapped(value * 1000, 0.1))

func _on_fov_changed(value: float) -> void:
	_update_fov_label(value)

func _update_fov_label(value: float) -> void:
	if fov_value:
		fov_value.text = str(int(value)) + "°"

func _on_master_volume_changed(value: float) -> void:
	_update_master_volume_label(value)

func _update_master_volume_label(value: float) -> void:
	if master_volume_value:
		master_volume_value.text = str(int(value * 100)) + "%"

func _on_save_pressed() -> void:
	# Save all settings
	if player_name_input:
		GameData.player_name = player_name_input.text.strip_edges()
		if GameData.player_name.is_empty():
			GameData.player_name = "Player"
	
	if sensitivity_slider:
		GameData.mouse_sensitivity = sensitivity_slider.value
	
	if fov_slider:
		GameData.field_of_view = fov_slider.value
	
	if master_volume_slider:
		GameData.master_volume = master_volume_slider.value
		# Apply audio volume
		AudioServer.set_bus_volume_db(0, linear_to_db(GameData.master_volume))
	
	GameData.save_settings()
	
	# Show saved feedback
	btn_save.text = "Saved!"
	await get_tree().create_timer(1.0).timeout
	btn_save.text = "Save"

func _on_back_pressed() -> void:
	SceneManager.go_to_main_menu()
