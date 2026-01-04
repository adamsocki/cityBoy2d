extends ScrollContainer

# Time Debug Tab - Controls for time of day debugging
# Extracted from original debug_time_panel.gd

# Node references
var time_value_label: Label
var normalized_time_slider: HSlider
var pause_button: Button
var reset_button: Button
var time_factor_slider: HSlider
var time_factor_label: Label
var distance_factor_slider: HSlider
var distance_factor_label: Label
var cycle_duration_slider: HSlider
var cycle_duration_label: Label
var game_time_label: Label
var distance_label: Label
var color_preview: ColorRect
var color_mode_button: Button

var is_paused: bool = false
var use_manual_colors: bool = false
var manual_normalized_time: float = 0.667
var updating_from_signal: bool = false

func _ready():
	_get_node_references()
	_apply_theme_roles()

	# Connect to TimeManager signals
	if TimeManager:
		TimeManager.continuous_time_changed.connect(_on_time_manager_continuous_time_changed)
		TimeManager.distance_contribution_updated.connect(_on_distance_contribution_updated)

	_initialize_ui()
	_connect_ui_signals()

func _apply_theme_roles() -> void:
	if time_value_label:
		time_value_label.set_meta("debug_theme_role", "header")
	if time_factor_label:
		time_factor_label.set_meta("debug_theme_role", "value")
	if distance_factor_label:
		distance_factor_label.set_meta("debug_theme_role", "value")
	if cycle_duration_label:
		cycle_duration_label.set_meta("debug_theme_role", "value")
	if game_time_label:
		game_time_label.set_meta("debug_theme_role", "value")
	if distance_label:
		distance_label.set_meta("debug_theme_role", "value")

func _get_node_references():
	time_value_label = find_child("TimeValueLabel", true, false) as Label
	normalized_time_slider = find_child("NormalizedTimeSlider", true, false) as HSlider
	pause_button = find_child("PauseButton", true, false) as Button
	reset_button = find_child("ResetButton", true, false) as Button
	time_factor_slider = find_child("TimeFactorSlider", true, false) as HSlider
	time_factor_label = find_child("TimeFactorLabel", true, false) as Label
	distance_factor_slider = find_child("DistanceFactorSlider", true, false) as HSlider
	distance_factor_label = find_child("DistanceFactorLabel", true, false) as Label
	cycle_duration_slider = find_child("CycleDurationSlider", true, false) as HSlider
	cycle_duration_label = find_child("CycleDurationLabel", true, false) as Label
	game_time_label = find_child("GameTimeLabel", true, false) as Label
	distance_label = find_child("DistanceLabel", true, false) as Label
	color_preview = find_child("ColorPreview", true, false) as ColorRect
	color_mode_button = find_child("ColorModeButton", true, false) as Button

func _initialize_ui():
	if not TimeManager:
		return

	normalized_time_slider.value = TimeManager.get_normalized_time()
	time_factor_slider.value = TimeManager.time_contribution_factor
	distance_factor_slider.value = TimeManager.distance_contribution_factor
	cycle_duration_slider.value = TimeManager.seconds_per_full_cycle

	_update_labels()

func _connect_ui_signals():
	normalized_time_slider.value_changed.connect(_on_time_slider_changed)
	pause_button.pressed.connect(_on_pause_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	time_factor_slider.value_changed.connect(_on_time_factor_changed)
	distance_factor_slider.value_changed.connect(_on_distance_factor_changed)
	cycle_duration_slider.value_changed.connect(_on_cycle_duration_changed)
	color_mode_button.pressed.connect(_on_color_mode_toggled)

	# Quick time buttons
	var quick_buttons = find_child("QuickTimeButtons", true, false)
	quick_buttons.get_node("DawnButton").pressed.connect(func(): _set_quick_time(0.0))
	quick_buttons.get_node("MidmorningButton").pressed.connect(func(): _set_quick_time(0.167))
	quick_buttons.get_node("NoonButton").pressed.connect(func(): _set_quick_time(0.333))
	quick_buttons.get_node("DuskButton").pressed.connect(func(): _set_quick_time(0.5))
	quick_buttons.get_node("EveningButton").pressed.connect(func(): _set_quick_time(0.667))
	quick_buttons.get_node("MidnightButton").pressed.connect(func(): _set_quick_time(0.833))

func _process(_delta):
	_update_labels()

func _update_labels():
	if not TimeManager:
		return

	var norm_time = TimeManager.get_normalized_time()
	var time_name = TimeManager.get_time_of_day_from_normalized(norm_time)

	time_value_label.text = "%s (%.3f)" % [time_name, norm_time]
	time_factor_label.text = "Time Factor: %.2f" % TimeManager.time_contribution_factor
	distance_factor_label.text = "Distance Factor: %.2f" % TimeManager.distance_contribution_factor
	cycle_duration_label.text = "Full Cycle: %ds (%.1fm)" % [
		TimeManager.seconds_per_full_cycle,
		TimeManager.seconds_per_full_cycle / 60.0
	]
	game_time_label.text = "Game Time: %.2fs" % TimeManager.get_game_time()
	distance_label.text = "Distance: %.1fm" % (TimeManager.get_distance_traveled() / 100.0)

	# Update color preview from SkyColorManager
	var sky_manager = get_tree().get_first_node_in_group("sky_color_manager")
	if sky_manager and sky_manager.sky_color_rect:
		color_preview.color = sky_manager.sky_color_rect.color

func _on_time_manager_continuous_time_changed(norm_time: float):
	if not updating_from_signal:
		updating_from_signal = true
		normalized_time_slider.value = norm_time
		updating_from_signal = false

func _on_distance_contribution_updated(distance: float, contribution: float):
	pass

func _on_time_slider_changed(value: float):
	if not updating_from_signal and TimeManager:
		manual_normalized_time = value
		if use_manual_colors:
			TimeManager.set_normalized_time(value)

func _on_pause_button_pressed():
	is_paused = !is_paused
	pause_button.text = "Resume" if is_paused else "Pause"

func _on_reset_button_pressed():
	if TimeManager:
		TimeManager.reset_time()
		TimeManager.reset_distance()

func _on_time_factor_changed(value: float):
	if TimeManager:
		var distance_factor = distance_factor_slider.value
		TimeManager.set_progression_factors(distance_factor, value)

func _on_distance_factor_changed(value: float):
	if TimeManager:
		var time_factor = time_factor_slider.value
		TimeManager.set_progression_factors(value, time_factor)

func _on_cycle_duration_changed(value: float):
	if TimeManager:
		TimeManager.seconds_per_full_cycle = value

func _on_color_mode_toggled():
	use_manual_colors = !use_manual_colors
	color_mode_button.text = "Manual" if use_manual_colors else "Auto"

func _set_quick_time(norm_time: float):
	if TimeManager:
		TimeManager.set_normalized_time(norm_time)
		normalized_time_slider.value = norm_time

func get_manual_normalized_time() -> float:
	return manual_normalized_time

func is_time_paused() -> bool:
	return is_paused
