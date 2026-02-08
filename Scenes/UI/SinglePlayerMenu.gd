extends Control

signal world_selected(world_name: String)

@onready var world_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/WorldList
@onready var btn_create_world: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/BtnCreateWorld
@onready var btn_back: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsRow/BtnBack
@onready var create_world_popup: Panel = $CreateWorldPopup if has_node("CreateWorldPopup") else null
@onready var world_name_input: LineEdit = $CreateWorldPopup/VBoxContainer/WorldNameInput if has_node("CreateWorldPopup/VBoxContainer/WorldNameInput") else null
@onready var btn_confirm_create: Button = $CreateWorldPopup/VBoxContainer/ButtonsRow/BtnConfirm if has_node("CreateWorldPopup/VBoxContainer/ButtonsRow/BtnConfirm") else null
@onready var btn_cancel_create: Button = $CreateWorldPopup/VBoxContainer/ButtonsRow/BtnCancel if has_node("CreateWorldPopup/VBoxContainer/ButtonsRow/BtnCancel") else null
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel

# World list items are created dynamically in _add_world_item()

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	btn_create_world.pressed.connect(_on_create_world_pressed)
	btn_back.pressed.connect(_on_back_pressed)
	
	if btn_confirm_create:
		btn_confirm_create.pressed.connect(_on_confirm_create_pressed)
	if btn_cancel_create:
		btn_cancel_create.pressed.connect(_on_cancel_create_pressed)
	
	if create_world_popup:
		create_world_popup.visible = false
	
	_refresh_world_list()

func _refresh_world_list() -> void:
	# Clear existing items
	for child in world_list.get_children():
		child.queue_free()
	
	# Get all worlds
	var worlds = GameData.get_all_worlds()
	
	if worlds.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No worlds found. Create a new world to start playing!"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		world_list.add_child(empty_label)
	else:
		for world_name in worlds:
			_add_world_item(world_name)

func _add_world_item(world_name: String) -> void:
	var world_data = GameData.load_world_data(world_name)
	
	# Create world item container
	var item_container = HBoxContainer.new()
	item_container.name = world_name
	item_container.add_theme_constant_override("separation", 10)
	
	# World info panel
	var info_panel = PanelContainer.new()
	info_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var info_vbox = VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 5)
	
	var name_label = Label.new()
	name_label.text = world_name
	name_label.add_theme_font_size_override("font_size", 20)
	
	var details_label = Label.new()
	var level_num = world_data.get("current_level", 0) + 1
	var created = world_data.get("created_at", "Unknown")
	details_label.text = "Level: " + str(level_num) + " | Created: " + created
	details_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	details_label.add_theme_font_size_override("font_size", 14)
	
	info_vbox.add_child(name_label)
	info_vbox.add_child(details_label)
	info_panel.add_child(info_vbox)
	
	# Play button
	var play_btn = Button.new()
	play_btn.text = "Play"
	play_btn.custom_minimum_size = Vector2(80, 50)
	play_btn.pressed.connect(_on_play_world.bind(world_name))
	
	# Delete button
	var delete_btn = Button.new()
	delete_btn.text = "Delete"
	delete_btn.custom_minimum_size = Vector2(80, 50)
	delete_btn.pressed.connect(_on_delete_world.bind(world_name))
	
	item_container.add_child(info_panel)
	item_container.add_child(play_btn)
	item_container.add_child(delete_btn)
	
	world_list.add_child(item_container)

func _on_create_world_pressed() -> void:
	if create_world_popup:
		create_world_popup.visible = true
		if world_name_input:
			world_name_input.text = ""
			world_name_input.grab_focus()
	else:
		# Fallback: create with default name
		var world_name = "World_" + str(randi() % 10000)
		_create_world(world_name)

func _on_confirm_create_pressed() -> void:
	if world_name_input and not world_name_input.text.strip_edges().is_empty():
		_create_world(world_name_input.text.strip_edges())
		if create_world_popup:
			create_world_popup.visible = false

func _on_cancel_create_pressed() -> void:
	if create_world_popup:
		create_world_popup.visible = false

func _create_world(world_name: String) -> void:
	if GameData.create_world(world_name):
		_refresh_world_list()
		# Auto-start the new world
		_on_play_world(world_name)
	else:
		# World already exists
		push_warning("World '" + world_name + "' already exists!")

func _on_play_world(world_name: String) -> void:
	world_selected.emit(world_name)
	SceneManager.start_game(world_name)

func _on_delete_world(world_name: String) -> void:
	if GameData.delete_world(world_name):
		_refresh_world_list()

func _on_back_pressed() -> void:
	SceneManager.go_to_main_menu()
