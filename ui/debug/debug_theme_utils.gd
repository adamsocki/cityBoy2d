class_name DebugThemeUtils
extends RefCounted

# =============================================================================
# Debug Panel Theme Utilities
# Static helper functions for creating and applying dark theme styles
# =============================================================================

# Get the DebugConfig singleton for color/size constants
static func _get_config() -> Node:
	return Engine.get_singleton("DebugConfig") if Engine.has_singleton("DebugConfig") else null

static func _get_debug_draw_manager() -> Node:
	var loop := Engine.get_main_loop()
	if loop is SceneTree:
		return loop.root.get_node_or_null("DebugDrawManager")
	return null

# Shorthand accessors for theme constants
static func get_color(key: String) -> Color:
	if DebugConfig.UI_COLORS.has(key):
		return DebugConfig.UI_COLORS[key]
	return Color.WHITE

static func get_font_size(key: String) -> int:
	var configured_default := int(DebugConfig.UI_FONTS.get("default_size", 14))
	var configured_value := int(DebugConfig.UI_FONTS.get(key, configured_default))

	var manager := _get_debug_draw_manager()
	if manager:
		var runtime_default := int(manager.get("ui_font_size"))
		var delta := runtime_default - configured_default
		return max(8, configured_value + delta)

	return configured_value

static func get_spacing(key: String) -> int:
	if DebugConfig.UI_SPACING.has(key):
		return DebugConfig.UI_SPACING[key]
	return 8

static func get_size(key: String) -> int:
	if DebugConfig.UI_SIZES.has(key):
		return DebugConfig.UI_SIZES[key]
	return 0

# =============================================================================
# StyleBox Creators
# =============================================================================

static func create_panel_stylebox() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("panel_bg")
	style.border_color = get_color("border")
	style.set_border_width_all(1)
	style.set_corner_radius_all(get_size("corner_radius"))
	style.set_content_margin_all(0)
	return style

static func create_title_bar_stylebox() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("title_bar_bg")
	style.border_color = get_color("border")
	style.border_width_bottom = 1
	style.set_corner_radius_all(0)
	style.corner_radius_top_left = get_size("corner_radius")
	style.corner_radius_top_right = get_size("corner_radius")
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

static func create_section_stylebox() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("section_bg")
	style.set_corner_radius_all(get_size("section_corner_radius"))
	style.set_content_margin_all(get_spacing("section_margin"))
	return style

static func create_section_header_stylebox(hover: bool = false) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("section_header_hover") if hover else get_color("section_header_bg")
	style.corner_radius_top_left = get_size("section_corner_radius")
	style.corner_radius_top_right = get_size("section_corner_radius")
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

static func create_section_body_stylebox() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("section_bg")
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = get_size("section_corner_radius")
	style.corner_radius_bottom_right = get_size("section_corner_radius")
	style.set_content_margin_all(get_spacing("section_margin"))
	return style

static func create_button_stylebox(state: String) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	match state:
		"normal":
			style.bg_color = get_color("button_normal")
		"hover":
			style.bg_color = get_color("button_hover")
		"pressed":
			style.bg_color = get_color("button_pressed")
		"disabled":
			style.bg_color = get_color("button_disabled")
		_:
			style.bg_color = get_color("button_normal")
	style.set_corner_radius_all(3)
	style.set_content_margin_all(6)
	return style

static func create_section_header_button_stylebox(state: String) -> StyleBoxFlat:
	match state:
		"hover", "pressed":
			return create_section_header_stylebox(true)
		_:
			return create_section_header_stylebox(false)

static func create_tab_stylebox(active: bool = false) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("tab_bg_active") if active else get_color("tab_bg")
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	style.set_content_margin_all(8)
	if active:
		style.border_color = get_color("border_accent")
		style.border_width_top = 2
	return style

static func create_tab_panel_stylebox() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("section_bg")
	style.set_corner_radius_all(0)
	style.corner_radius_bottom_left = get_size("corner_radius")
	style.corner_radius_bottom_right = get_size("corner_radius")
	style.set_content_margin_all(get_spacing("section_margin"))
	return style

static func create_slider_stylebox() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("slider_bg")
	style.set_corner_radius_all(2)
	style.set_content_margin_all(0)
	return style

static func create_slider_fill_stylebox() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("slider_fill")
	style.set_corner_radius_all(2)
	return style

static func create_slider_grabber_stylebox() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = get_color("slider_grabber")
	style.set_corner_radius_all(6)
	style.set_content_margin_all(0)
	return style

static func create_empty_stylebox() -> StyleBoxEmpty:
	return StyleBoxEmpty.new()

static func create_separator_stylebox() -> StyleBoxLine:
	var style = StyleBoxLine.new()
	style.color = get_color("separator")
	style.thickness = 1
	return style

# =============================================================================
# Label Styling
# =============================================================================

static func apply_label_style(label: Label, style_type: String = "primary") -> void:
	match style_type:
		"primary":
			label.add_theme_color_override("font_color", get_color("text_primary"))
			label.add_theme_font_size_override("font_size", get_font_size("default_size"))
		"secondary":
			label.add_theme_color_override("font_color", get_color("text_secondary"))
			label.add_theme_font_size_override("font_size", get_font_size("default_size"))
		"value":
			label.add_theme_color_override("font_color", get_color("text_value"))
			label.add_theme_font_size_override("font_size", get_font_size("default_size"))
		"header":
			label.add_theme_color_override("font_color", get_color("text_header"))
			label.add_theme_font_size_override("font_size", get_font_size("header_size"))
		"title":
			label.add_theme_color_override("font_color", get_color("text_primary"))
			label.add_theme_font_size_override("font_size", get_font_size("title_size"))
		"muted":
			label.add_theme_color_override("font_color", get_color("text_muted"))
			label.add_theme_font_size_override("font_size", get_font_size("small_size"))
		_:
			label.add_theme_color_override("font_color", get_color("text_primary"))

# =============================================================================
# Button Styling
# =============================================================================

static func style_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", create_button_stylebox("normal"))
	button.add_theme_stylebox_override("hover", create_button_stylebox("hover"))
	button.add_theme_stylebox_override("pressed", create_button_stylebox("pressed"))
	button.add_theme_stylebox_override("disabled", create_button_stylebox("disabled"))
	button.add_theme_color_override("font_color", get_color("text_primary"))
	button.add_theme_color_override("font_hover_color", get_color("text_primary"))
	button.add_theme_color_override("font_pressed_color", get_color("text_secondary"))
	button.add_theme_color_override("font_disabled_color", get_color("text_muted"))
	button.add_theme_font_size_override("font_size", get_font_size("default_size"))

static func style_icon_button(button: Button) -> void:
	style_button(button)
	button.custom_minimum_size = Vector2(28, 28)

static func style_section_header_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", create_section_header_button_stylebox("normal"))
	button.add_theme_stylebox_override("hover", create_section_header_button_stylebox("hover"))
	button.add_theme_stylebox_override("pressed", create_section_header_button_stylebox("pressed"))
	button.add_theme_stylebox_override("disabled", create_section_header_button_stylebox("disabled"))
	button.add_theme_color_override("font_color", get_color("text_header"))
	button.add_theme_color_override("font_hover_color", get_color("text_header"))
	button.add_theme_color_override("font_pressed_color", get_color("text_header"))
	button.add_theme_color_override("font_disabled_color", get_color("text_muted"))
	button.add_theme_font_size_override("font_size", get_font_size("header_size"))

# =============================================================================
# Slider Styling
# =============================================================================

static func style_slider(slider: HSlider) -> void:
	slider.add_theme_stylebox_override("slider", create_slider_stylebox())
	slider.add_theme_stylebox_override("grabber_area", create_slider_fill_stylebox())
	slider.add_theme_stylebox_override("grabber_area_highlight", create_slider_fill_stylebox())

	# Grabber icons - we use styleboxes for visual consistency
	var grabber_style = create_slider_grabber_stylebox()
	slider.add_theme_icon_override("grabber", _create_grabber_texture(get_color("slider_grabber")))
	slider.add_theme_icon_override("grabber_highlight", _create_grabber_texture(get_color("slider_grabber").lightened(0.2)))

static func _create_grabber_texture(color: Color) -> ImageTexture:
	# Create a simple circular grabber
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	var center = Vector2(8, 8)
	var radius = 6.0

	for x in range(16):
		for y in range(16):
			var dist = Vector2(x, y).distance_to(center)
			if dist <= radius:
				img.set_pixel(x, y, color)
			elif dist <= radius + 1:
				var alpha = 1.0 - (dist - radius)
				img.set_pixel(x, y, Color(color.r, color.g, color.b, alpha))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))

	return ImageTexture.create_from_image(img)

# =============================================================================
# CheckButton Styling
# =============================================================================

static func style_check_button(check: CheckButton) -> void:
	check.add_theme_color_override("font_color", get_color("text_primary"))
	check.add_theme_color_override("font_hover_color", get_color("text_primary"))
	check.add_theme_color_override("font_pressed_color", get_color("text_secondary"))
	check.add_theme_font_size_override("font_size", get_font_size("default_size"))

	# Create custom check icons
	check.add_theme_icon_override("checked", _create_check_icon(true))
	check.add_theme_icon_override("unchecked", _create_check_icon(false))

static func _create_check_icon(checked: bool) -> ImageTexture:
	var size = 18
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)

	var bg_color = get_color("check_on") if checked else get_color("check_off")
	var border_color = get_color("border")

	# Draw rounded rectangle background
	for x in range(size):
		for y in range(size):
			var is_border = x == 0 or x == size - 1 or y == 0 or y == size - 1
			if is_border:
				img.set_pixel(x, y, border_color)
			else:
				img.set_pixel(x, y, bg_color)

	# Draw checkmark if checked
	if checked:
		var check_color = get_color("text_primary")
		# Simple checkmark shape
		for i in range(3):
			img.set_pixel(4 + i, 9 + i, check_color)
			img.set_pixel(5 + i, 9 + i, check_color)
		for i in range(6):
			img.set_pixel(7 + i, 11 - i, check_color)
			img.set_pixel(8 + i, 11 - i, check_color)

	return ImageTexture.create_from_image(img)

# =============================================================================
# TabContainer Styling
# =============================================================================

static func style_tab_container(tab_container: TabContainer) -> void:
	tab_container.add_theme_stylebox_override("panel", create_tab_panel_stylebox())
	tab_container.add_theme_stylebox_override("tab_selected", create_tab_stylebox(true))
	tab_container.add_theme_stylebox_override("tab_unselected", create_tab_stylebox(false))
	tab_container.add_theme_stylebox_override("tab_hovered", create_tab_stylebox(false))
	tab_container.add_theme_color_override("font_selected_color", get_color("text_primary"))
	tab_container.add_theme_color_override("font_unselected_color", get_color("text_secondary"))
	tab_container.add_theme_color_override("font_hovered_color", get_color("text_primary"))
	tab_container.add_theme_font_size_override("font_size", get_font_size("default_size"))

# =============================================================================
# Container Styling
# =============================================================================

static func style_panel_container(panel: PanelContainer) -> void:
	panel.add_theme_stylebox_override("panel", create_panel_stylebox())

static func style_title_bar(panel: PanelContainer) -> void:
	panel.add_theme_stylebox_override("panel", create_title_bar_stylebox())

static func style_section_panel(panel: PanelContainer) -> void:
	panel.add_theme_stylebox_override("panel", create_section_body_stylebox())

static func style_vbox(vbox: VBoxContainer, spacing: int = -1) -> void:
	if vbox.has_theme_constant_override("separation"):
		return
	if spacing < 0:
		spacing = get_spacing("item_spacing")
	vbox.add_theme_constant_override("separation", spacing)

static func style_hbox(hbox: HBoxContainer, spacing: int = -1) -> void:
	if hbox.has_theme_constant_override("separation"):
		return
	if spacing < 0:
		spacing = get_spacing("item_spacing")
	hbox.add_theme_constant_override("separation", spacing)

static func style_margin_container(margin: MarginContainer, margin_size: int = -1) -> void:
	if margin_size < 0:
		margin_size = get_spacing("panel_margin")
	margin.add_theme_constant_override("margin_left", margin_size)
	margin.add_theme_constant_override("margin_right", margin_size)
	margin.add_theme_constant_override("margin_top", margin_size)
	margin.add_theme_constant_override("margin_bottom", margin_size)

# =============================================================================
# Separator Styling
# =============================================================================

static func style_separator(sep: HSeparator) -> void:
	var style = StyleBoxLine.new()
	style.color = get_color("separator")
	style.thickness = 1
	style.grow_begin = 0
	style.grow_end = 0
	sep.add_theme_stylebox_override("separator", style)

# =============================================================================
# Utility Functions
# =============================================================================

static var _monospace_font: Font = null

static func get_monospace_font() -> Font:
	if _monospace_font == null:
		var font := SystemFont.new()
		font.font_names = PackedStringArray([
			"JetBrains Mono",
			"Menlo",
			"Consolas",
			"Courier New",
			"monospace",
		])
		_monospace_font = font
	return _monospace_font

static func apply_theme_recursive(node: Control) -> void:
	if node.has_meta("debug_theme_role"):
		var role := str(node.get_meta("debug_theme_role"))
		match role:
			"title_bar":
				if node is PanelContainer:
					style_title_bar(node)
			"section_body":
				if node is PanelContainer:
					style_section_panel(node)
			"section_header":
				if node is Button:
					style_section_header_button(node)
			"mono_value":
				if node is Label:
					apply_label_style(node, "value")
					node.add_theme_font_override("font", get_monospace_font())
			"primary", "secondary", "value", "header", "title", "muted":
				if node is Label:
					apply_label_style(node, role)

	# Apply appropriate styling based on node type
	if node is Label:
		if not node.has_meta("debug_theme_role"):
			apply_label_style(node, "secondary")
	elif node is Button and not node is CheckButton:
		if node.has_meta("debug_theme_role") and str(node.get_meta("debug_theme_role")) == "section_header":
			style_section_header_button(node)
		else:
			style_button(node)
	elif node is CheckButton:
		style_check_button(node)
	elif node is HSlider:
		style_slider(node)
	elif node is TabContainer:
		style_tab_container(node)
	elif node is HSeparator:
		style_separator(node)
	elif node is PanelContainer:
		if not node.has_meta("debug_theme_role"):
			style_panel_container(node)
	elif node is VBoxContainer:
		style_vbox(node)
	elif node is HBoxContainer:
		style_hbox(node)

	# Recurse into children
	for child in node.get_children():
		if child is Control:
			apply_theme_recursive(child)
