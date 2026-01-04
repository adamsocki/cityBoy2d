extends HBoxContainer

# Debug Controls Section - UI controls for font size and position

# Node references
var font_label: Label
var decrease_font_button: Button
var increase_font_button: Button
var reset_position_button: Button

@onready var debug_draw_manager = get_node_or_null("/root/DebugDrawManager")

func _ready():
	_create_controls()
	_connect_signals()
	_update_font_label()
	_apply_theme()

func _create_controls():
	# Font size controls
	font_label = Label.new()
	font_label.text = "Font: 14"
	add_child(font_label)

	decrease_font_button = Button.new()
	decrease_font_button.text = "-"
	add_child(decrease_font_button)

	increase_font_button = Button.new()
	increase_font_button.text = "+"
	add_child(increase_font_button)

	# Add spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(20, 0)
	add_child(spacer)

	# Reset position button
	reset_position_button = Button.new()
	reset_position_button.text = "Reset Position"
	add_child(reset_position_button)

func _connect_signals():
	decrease_font_button.pressed.connect(_on_decrease_font_pressed)
	increase_font_button.pressed.connect(_on_increase_font_pressed)
	reset_position_button.pressed.connect(_on_reset_position_pressed)

	if debug_draw_manager:
		debug_draw_manager.ui_settings_changed.connect(_on_ui_settings_changed)

func _update_font_label():
	if debug_draw_manager:
		font_label.text = "Font: " + str(debug_draw_manager.ui_font_size)

func _apply_theme() -> void:
	font_label.set_meta("debug_theme_role", "muted")
	DebugThemeUtils.style_icon_button(decrease_font_button)
	DebugThemeUtils.style_icon_button(increase_font_button)
	DebugThemeUtils.style_button(reset_position_button)

func _on_decrease_font_pressed():
	if debug_draw_manager:
		debug_draw_manager.decrease_font_size()

func _on_increase_font_pressed():
	if debug_draw_manager:
		debug_draw_manager.increase_font_size()

func _on_reset_position_pressed():
	if debug_draw_manager:
		debug_draw_manager.reset_ui_position()

func _on_ui_settings_changed(_font_size: int, _position: Vector2):
	_update_font_label()
