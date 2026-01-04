extends Control

const _DEBUG_CONTROLS_SECTION_SCRIPT := preload("res://ui/debug/debug_controls_section.gd")

# Node references
var minimized_bar: PanelContainer
var minimized_title_label: Label
var expand_button: Button

var expanded_panel: PanelContainer
var title_bar: PanelContainer
var expanded_title_label: Label
var minimize_button: Button
var controls_host: HBoxContainer
var tab_container: TabContainer
var time_tab: Node
var reload_button: Button
var separator1: HSeparator
var separator2: HSeparator

var resize_right: Control
var resize_bottom: Control
var resize_corner: ColorRect

# Panel state
var is_minimized: bool = false
var expanded_size: Vector2 = Vector2(400, 500)

# Drag state
var is_dragging: bool = false

# Resize state
var is_resizing: bool = false
var resize_mode: String = ""  # "right", "bottom", "corner"

var _minimized_height: float = 32.0
var _min_panel_size: Vector2 = Vector2(320, 250)
var _max_panel_size: Vector2 = Vector2(800, 900)

var _last_font_size: int = -1

@onready var debug_draw_manager = get_node_or_null("/root/DebugDrawManager")

func _ready() -> void:
	_get_node_references()
	_setup_controls_section()
	_connect_signals()
	_apply_initial_state()
	_apply_theme()

func _get_node_references() -> void:
	minimized_bar = $MinimizedBar
	minimized_title_label = $MinimizedBar/BarRow/TitleLabel
	expand_button = $MinimizedBar/BarRow/ExpandButton

	expanded_panel = $ExpandedPanel
	title_bar = $ExpandedPanel/MarginContainer/VBoxContainer/TitleBar
	expanded_title_label = $ExpandedPanel/MarginContainer/VBoxContainer/TitleBar/HBoxContainer/TitleLabel
	minimize_button = $ExpandedPanel/MarginContainer/VBoxContainer/TitleBar/HBoxContainer/MinimizeButton
	controls_host = $ExpandedPanel/MarginContainer/VBoxContainer/ControlsHost
	tab_container = $ExpandedPanel/MarginContainer/VBoxContainer/TabContainer
	time_tab = tab_container.get_node_or_null("Time")
	separator1 = $ExpandedPanel/MarginContainer/VBoxContainer/Separator1
	separator2 = $ExpandedPanel/MarginContainer/VBoxContainer/Separator2
	reload_button = $ExpandedPanel/MarginContainer/VBoxContainer/ReloadButton

	resize_right = $ResizeRight
	resize_bottom = $ResizeBottom
	resize_corner = $ResizeCorner

	minimized_bar.set_meta("debug_theme_role", "title_bar")
	title_bar.set_meta("debug_theme_role", "title_bar")
	minimized_title_label.set_meta("debug_theme_role", "title")
	expanded_title_label.set_meta("debug_theme_role", "title")

func _setup_controls_section() -> void:
	if controls_host.get_child_count() > 0:
		return

	var controls_section: Control = _DEBUG_CONTROLS_SECTION_SCRIPT.new()
	controls_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_host.add_child(controls_section)

func _connect_signals() -> void:
	reload_button.pressed.connect(_on_reload_button_pressed)
	minimize_button.pressed.connect(toggle_minimize)
	expand_button.pressed.connect(toggle_minimize)

	title_bar.mouse_default_cursor_shape = CURSOR_MOVE
	minimized_bar.mouse_default_cursor_shape = CURSOR_MOVE

	title_bar.gui_input.connect(_on_drag_gui_input)
	minimized_bar.gui_input.connect(_on_drag_gui_input)

	resize_right.mouse_default_cursor_shape = CURSOR_HSIZE
	resize_bottom.mouse_default_cursor_shape = CURSOR_VSIZE
	resize_corner.mouse_default_cursor_shape = CURSOR_FDIAGSIZE

	resize_right.gui_input.connect(_on_resize_gui_input.bind("right"))
	resize_bottom.gui_input.connect(_on_resize_gui_input.bind("bottom"))
	resize_corner.gui_input.connect(_on_resize_gui_input.bind("corner"))

	resize_right.mouse_filter = Control.MOUSE_FILTER_STOP
	resize_bottom.mouse_filter = Control.MOUSE_FILTER_STOP
	resize_corner.mouse_filter = Control.MOUSE_FILTER_STOP

	if debug_draw_manager:
		debug_draw_manager.ui_settings_changed.connect(_on_ui_settings_changed)
		debug_draw_manager.ui_panel_state_changed.connect(_on_ui_panel_state_changed)

func _apply_initial_state() -> void:
	_minimized_height = float(DebugConfig.UI_SIZES.get("minimized_height", 32))
	_min_panel_size = Vector2(
		float(DebugConfig.UI_SIZES.get("min_panel_width", 320)),
		float(DebugConfig.UI_SIZES.get("min_panel_height", 250))
	)
	_max_panel_size = Vector2(
		float(DebugConfig.UI_SIZES.get("max_panel_width", 800)),
		float(DebugConfig.UI_SIZES.get("max_panel_height", 900))
	)

	if debug_draw_manager:
		position = debug_draw_manager.ui_position
		expanded_size = debug_draw_manager.ui_size
		is_minimized = debug_draw_manager.ui_minimized
		_last_font_size = debug_draw_manager.ui_font_size
	else:
		expanded_size = size

	expanded_size = _clamp_panel_size(expanded_size)
	_apply_panel_rect_for_state(false)

# Tab management methods
func switch_to_tab(tab_index: int) -> void:
	if tab_container and tab_index >= 0 and tab_index < tab_container.get_tab_count():
		tab_container.current_tab = tab_index

func get_current_tab() -> int:
	if tab_container:
		return tab_container.current_tab
	return 0

# Legacy compatibility methods (delegate to time tab)
func get_manual_normalized_time() -> float:
	if time_tab and time_tab.has_method("get_manual_normalized_time"):
		return time_tab.get_manual_normalized_time()
	return 0.667  # Fallback

func is_time_paused() -> bool:
	if time_tab and time_tab.has_method("is_time_paused"):
		return time_tab.is_time_paused()
	return false  # Fallback

func toggle_minimize() -> void:
	is_minimized = not is_minimized
	_apply_panel_rect_for_state(true)

func _apply_panel_rect_for_state(save_to_manager: bool) -> void:
	expanded_panel.visible = not is_minimized
	minimized_bar.visible = is_minimized

	resize_right.visible = not is_minimized
	resize_bottom.visible = not is_minimized
	resize_corner.visible = not is_minimized

	if is_minimized:
		size = Vector2(expanded_size.x, _minimized_height)
	else:
		size = expanded_size

	_clamp_position_to_viewport()

	if save_to_manager and debug_draw_manager:
		debug_draw_manager.set_ui_minimized(is_minimized)
		debug_draw_manager.set_ui_size(expanded_size)

# Reload current scene
func _on_reload_button_pressed() -> void:
	get_tree().reload_current_scene()
	print("Scene reloaded - native collision shapes should now be visible")

func _on_ui_settings_changed(font_size: int, new_position: Vector2) -> void:
	position = new_position
	if font_size != _last_font_size:
		_last_font_size = font_size
		_apply_theme()

func _on_ui_panel_state_changed(minimized: bool, new_size: Vector2) -> void:
	is_minimized = minimized
	expanded_size = _clamp_panel_size(new_size)
	_apply_panel_rect_for_state(false)

func _on_drag_gui_input(event: InputEvent) -> void:
	if is_resizing:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
		else:
			if is_dragging:
				is_dragging = false
				if debug_draw_manager:
					debug_draw_manager.set_ui_position(position)

	elif event is InputEventMouseMotion and is_dragging:
		position += event.relative
		_clamp_position_to_viewport()

func _on_resize_gui_input(event: InputEvent, mode: String) -> void:
	if is_minimized:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_resizing = true
			resize_mode = mode
		else:
			if is_resizing and resize_mode == mode:
				is_resizing = false
				resize_mode = ""
				if debug_draw_manager:
					debug_draw_manager.set_ui_size(expanded_size)

	elif event is InputEventMouseMotion and is_resizing and resize_mode == mode:
		var motion_event := event as InputEventMouseMotion
		var delta: Vector2 = motion_event.relative
		var new_size: Vector2 = expanded_size
		if mode == "right" or mode == "corner":
			new_size.x += delta.x
		if mode == "bottom" or mode == "corner":
			new_size.y += delta.y

		expanded_size = _clamp_panel_size(new_size)
		_apply_panel_rect_for_state(false)

func _clamp_panel_size(value: Vector2) -> Vector2:
	return Vector2(
		clampf(value.x, _min_panel_size.x, _max_panel_size.x),
		clampf(value.y, _min_panel_size.y, _max_panel_size.y)
	)

func _clamp_position_to_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	var margin := 20.0
	position.x = clampf(position.x, -size.x + margin, viewport_size.x - margin)
	position.y = clampf(position.y, 0.0, viewport_size.y - margin)

func _apply_theme() -> void:
	DebugThemeUtils.apply_theme_recursive(expanded_panel)
	DebugThemeUtils.apply_theme_recursive(minimized_bar)

	DebugThemeUtils.style_icon_button(expand_button)
	DebugThemeUtils.style_icon_button(minimize_button)

	resize_corner.color = DebugThemeUtils.get_color("resize_handle")
