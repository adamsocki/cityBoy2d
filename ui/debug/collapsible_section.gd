class_name CollapsibleSection
extends VBoxContainer

signal toggled(collapsed: bool)

@export var section_title: String = "Section" : set = _set_section_title
@export var start_collapsed: bool = false

var is_collapsed: bool = false
var header: Button
var content: VBoxContainer
var icon: Label

var _content_panel: PanelContainer
var _title_label: Label

func _ready() -> void:
	# Capture any children authored in the editor and move them into the content container.
	var authored_children: Array[Node] = []
	for child in get_children():
		authored_children.append(child)

	_build_chrome()

	for child in authored_children:
		if child == header or child == _content_panel:
			continue
		remove_child(child)
		content.add_child(child)

	is_collapsed = start_collapsed
	_update_collapsed_state()

func _build_chrome() -> void:
	add_theme_constant_override("separation", 0)

	header = Button.new()
	header.name = "Header"
	header.flat = true
	header.focus_mode = Control.FOCUS_NONE
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.set_meta("debug_theme_role", "section_header")
	add_child(header)

	var header_margin = MarginContainer.new()
	header_margin.name = "HeaderMargin"
	header_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	header_margin.add_theme_constant_override("margin_left", 8)
	header_margin.add_theme_constant_override("margin_right", 8)
	header_margin.add_theme_constant_override("margin_top", 6)
	header_margin.add_theme_constant_override("margin_bottom", 6)
	header.add_child(header_margin)

	var header_row = HBoxContainer.new()
	header_row.name = "HeaderRow"
	header_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_margin.add_child(header_row)

	icon = Label.new()
	icon.name = "Icon"
	icon.set_meta("debug_theme_role", "muted")
	header_row.add_child(icon)

	_title_label = Label.new()
	_title_label.name = "Title"
	_title_label.text = section_title
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.set_meta("debug_theme_role", "header")
	header_row.add_child(_title_label)

	_content_panel = PanelContainer.new()
	_content_panel.name = "ContentPanel"
	_content_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_panel.set_meta("debug_theme_role", "section_body")
	add_child(_content_panel)

	content = VBoxContainer.new()
	content.name = "Content"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_panel.add_child(content)

	header.pressed.connect(_on_header_pressed)

func _set_section_title(value: String) -> void:
	section_title = value
	if _title_label:
		_title_label.text = section_title

func _on_header_pressed() -> void:
	set_collapsed(not is_collapsed)

func set_collapsed(collapsed: bool) -> void:
	if is_collapsed == collapsed:
		return
	is_collapsed = collapsed
	_update_collapsed_state()
	toggled.emit(is_collapsed)

func _update_collapsed_state() -> void:
	if icon:
		icon.text = ">" if is_collapsed else "v"
	if _content_panel:
		_content_panel.visible = not is_collapsed

func add_content(node: Node) -> void:
	if not content:
		return
	content.add_child(node)

func get_content_container() -> VBoxContainer:
	return content
