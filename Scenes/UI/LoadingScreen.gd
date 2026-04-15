# LoadingScreen.gd - Beautiful loading screen with progress indicators
extends Control
class_name LoadingScreen

signal loading_complete

@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressContainer/ProgressBar
@onready var progress_label: Label = $VBoxContainer/ProgressContainer/ProgressLabel
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var tip_label: Label = $VBoxContainer/TipLabel
@onready var time_label: Label = $VBoxContainer/TimeContainer/TimeLabel
@onready var pulse_indicator: Control = $VBoxContainer/PulseIndicator

# Loading tips to display
const LOADING_TIPS: Array[String] = [
	"💡 TIP: Use checkpoints to save your progress automatically.",
	"⚔️ TIP: Time your attacks carefully for maximum damage.",
	"🏃 TIP: Hold Shift to sprint when escaping enemies.",
	"🎯 TIP: Mobs will chase you if you get too close.",
	"🛡️ TIP: Use the environment to your advantage in combat.",
	"🗺️ TIP: Complete levels to unlock new challenges.",
	"👥 TIP: Pause the game to open it to LAN for friends to join.",
	"💀 TIP: Bosses require multiple hits to defeat.",
]

# Status messages for different loading phases
const STATUS_MESSAGES: Dictionary = {
	0.0: "Initializing...",
	0.1: "Loading game assets...",
	0.25: "Preparing world data...",
	0.4: "Loading level geometry...",
	0.55: "Spawning entities...",
	0.7: "Setting up lighting...",
	0.85: "Finalizing...",
	0.95: "Almost ready...",
	1.0: "Complete!"
}

var _start_time: float = 0.0
var _current_progress: float = 0.0
var _target_progress: float = 0.0
var _pulse_scale: float = 1.0
var _pulse_direction: float = 1.0
var _tip_timer: float = 0.0
var _current_tip_index: int = 0
var _is_loading: bool = false
var _last_progress_time: float = 0.0
var _freeze_warning_shown: bool = false

func _ready() -> void:
	_start_time = Time.get_ticks_msec() / 1000.0
	_last_progress_time = _start_time
	_current_tip_index = randi() % LOADING_TIPS.size()
	
	# Initialize UI elements
	if progress_bar:
		progress_bar.value = 0
	if progress_label:
		progress_label.text = "0%"
	if status_label:
		status_label.text = "Initializing..."
	if tip_label:
		tip_label.text = LOADING_TIPS[_current_tip_index]
	if time_label:
		time_label.text = "Elapsed: 0.0s"
	
	_is_loading = true

func _process(delta: float) -> void:
	if not _is_loading:
		return
	

	# Animate pulse indicator
	_animate_pulse(delta)
	
	# Smooth progress bar animation
	_animate_progress(delta)
	
	# Update elapsed time
	_update_time()
	
	# Rotate tips every 4 seconds
	_tip_timer += delta
	if _tip_timer >= 4.0:
		_tip_timer = 0.0
		_rotate_tip()
	
	# Check for freeze (no progress for 10 seconds)
	_check_freeze()


func _animate_pulse(delta: float) -> void:
	if pulse_indicator:
		_pulse_scale += _pulse_direction * delta * 0.5
		if _pulse_scale >= 1.2:
			_pulse_direction = -1.0
		elif _pulse_scale <= 0.8:
			_pulse_direction = 1.0
		pulse_indicator.scale = Vector2(_pulse_scale, _pulse_scale)

func _animate_progress(delta: float) -> void:
	# Smooth lerp to target progress
	_current_progress = lerp(_current_progress, _target_progress, delta * 3.0)
	
	if progress_bar:
		progress_bar.value = _current_progress * 100.0
	if progress_label:
		progress_label.text = str(int(_current_progress * 100)) + "%"

func _update_time() -> void:
	var elapsed = (Time.get_ticks_msec() / 1000.0) - _start_time
	if time_label:
		time_label.text = "Elapsed: " + str(snapped(elapsed, 0.1)) + "s"

func _check_freeze() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# If no progress for 10 seconds, show warning
	if current_time - _last_progress_time > 10.0 and not _freeze_warning_shown:
		_freeze_warning_shown = true
		if status_label:
			status_label.text = "⚠️ Loading is taking longer than expected..."
			status_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))

func _rotate_tip() -> void:
	_current_tip_index = (_current_tip_index + 1) % LOADING_TIPS.size()
	if tip_label:
		# Fade out/in animation
		var tween = create_tween()
		tween.tween_property(tip_label, "modulate:a", 0.0, 0.2)
		tween.tween_callback(func(): tip_label.text = LOADING_TIPS[_current_tip_index])
		tween.tween_property(tip_label, "modulate:a", 1.0, 0.2)

func update_progress(progress: float) -> void:
	_target_progress = clamp(progress, 0.0, 1.0)
	_last_progress_time = Time.get_ticks_msec() / 1000.0
	_freeze_warning_shown = false
	
	# Update status message based on progress
	_update_status_message(progress)

func _update_status_message(progress: float) -> void:
	var message = "Loading..."
	var last_threshold = 0.0
	
	for threshold in STATUS_MESSAGES.keys():
		if progress >= threshold and threshold >= last_threshold:
			message = STATUS_MESSAGES[threshold]
			last_threshold = threshold
	
	if status_label:
		status_label.text = message
		# Reset color if freeze warning was shown
		if not _freeze_warning_shown:
			status_label.remove_theme_color_override("font_color")

func complete_loading() -> void:
	_is_loading = false
	_target_progress = 1.0
	_current_progress = 1.0
	
	if progress_bar:
		progress_bar.value = 100
	if progress_label:
		progress_label.text = "100%"
	if status_label:
		status_label.text = "✓ Loading Complete!"
		status_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	
	# Brief delay before transitioning
	await get_tree().create_timer(0.5).timeout
	loading_complete.emit()

func show_error(error_message: String) -> void:
	_is_loading = false
	
	if status_label:
		status_label.text = "❌ Error: " + error_message
		status_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	if tip_label:
		tip_label.text = "Please restart the game or try again."
