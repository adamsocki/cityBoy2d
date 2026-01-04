extends Node

# Debug Draw Manager Singleton
# Central state management for all debug visualization features

# Signals
signal debug_state_changed(feature_name: String, enabled: bool)
signal debug_colors_updated()
signal ui_settings_changed(font_size: int, position: Vector2)
signal ui_panel_state_changed(minimized: bool, size: Vector2)

# Native Godot Debug Features
var native_collision_shapes: bool = false  # Uses Godot's built-in collision visualization

# Physics Debug Features
var draw_collision_shapes: bool = false
var draw_raycasts: bool = false
var draw_velocity_vectors: bool = false
var draw_state_info: bool = false
var draw_hitboxes: bool = false

# Level Debug Features
var draw_level_transitions: bool = false
var draw_spawn_points: bool = false
var draw_interactive_areas: bool = false
var draw_camera_dead_zones: bool = false
var draw_viewport_edges: bool = false

# UI Settings
var ui_font_size: int = 14  # Default font size for debug labels
var ui_position: Vector2 = Vector2(10, 10)  # Default panel position
var ui_minimized: bool = false
var ui_size: Vector2 = Vector2(400, 500)
const MIN_FONT_SIZE = 10
const MAX_FONT_SIZE = 24
const DEFAULT_POSITION = Vector2(10, 10)
const DEFAULT_SIZE = Vector2(400, 500)
const UI_CONFIG_PATH = "user://debug_ui_config.json"

# Valid feature keys for property-based access.
const DEBUG_FEATURES = {
	"native_collision_shapes": true,
	"draw_collision_shapes": true,
	"draw_raycasts": true,
	"draw_velocity_vectors": true,
	"draw_state_info": true,
	"draw_hitboxes": true,
	"draw_level_transitions": true,
	"draw_spawn_points": true,
	"draw_interactive_areas": true,
	"draw_camera_dead_zones": true,
	"draw_viewport_edges": true,
}

# Color configuration with semantic color scheme
var colors = {
	# Navigation/Spawning (Green/Yellow tones)
	"spawn_point": Color(0.2, 1.0, 0.2, 0.6),      # Bright green - safe spawn
	"spawn_checkpoint": Color(1.0, 0.8, 0.2, 0.6),  # Yellow - important checkpoint

	# Transitions/Triggers (Blue tones)
	"level_transition": Color(0.2, 0.5, 1.0, 0.4),  # Blue - portal/exit
	"interactive_area": Color(0.7, 0.2, 1.0, 0.4),  # Purple - interactable

	# Physics/Collisions (Red/Orange tones)
	"collision_shape": Color(1.0, 0.2, 0.2, 0.5),   # Red - danger/solid
	"raycast": Color(1.0, 0.5, 0.0, 0.7),           # Orange - detection ray
	"raycast_hit": Color(0.2, 1.0, 0.2, 0.8),       # Green - successful hit
	"raycast_miss": Color(1.0, 0.2, 0.2, 0.7),      # Red - no collision

	# Movement/Velocity (Cyan tones)
	"velocity_vector": Color(0.0, 1.0, 1.0, 0.8),   # Cyan - motion

	# Camera/View (Transparent red)
	"dead_zone": Color(1.0, 0.0, 0.0, 0.2),         # Very transparent - subtle

	# Text
	"label_text": Color(1.0, 1.0, 1.0, 1.0),        # White text
	"label_background": Color(0.0, 0.0, 0.0, 0.7),  # Semi-transparent black
}

# Line width configuration
var line_widths = {
	"default": 2.0,
	"thin": 1.0,
	"thick": 3.0,
}

func _ready():
	# Singleton initialization
	load_ui_settings()

func _is_valid_debug_feature(feature: String) -> bool:
	return DEBUG_FEATURES.has(feature)

# Set a debug feature's enabled state
func set_debug_feature(feature: String, enabled: bool) -> void:
	if _is_valid_debug_feature(feature) and get(feature) != enabled:
		set(feature, enabled)

		# Special handling for native collision shapes
		if feature == "native_collision_shapes":
			_set_native_collision_shapes(enabled)

		debug_state_changed.emit(feature, enabled)

# Enable/disable Godot's native collision shape visualization
func _set_native_collision_shapes(enabled: bool) -> void:
	if not get_tree():
		return

	get_tree().debug_collisions_hint = enabled

	# Note: Godot's collision debug rendering is initialized when scenes load.
	# If toggling mid-scene doesn't show shapes, they'll appear after transitioning to another level.
	# For immediate visibility, the scene needs to be reloaded.

# Check if a debug feature is enabled
func is_debug_enabled(feature: String) -> bool:
	if _is_valid_debug_feature(feature):
		return get(feature)
	return false

# Get color for a specific debug element type
func get_debug_color(element_type: String) -> Color:
	if colors.has(element_type):
		return colors[element_type]
	return Color.WHITE  # Fallback color

# Get line width for drawing
func get_line_width(width_type: String = "default") -> float:
	if line_widths.has(width_type):
		return line_widths[width_type]
	return 2.0  # Fallback width

# Enable all debug features (useful for "Show All" button)
func enable_all_physics_debug() -> void:
	set_debug_feature("native_collision_shapes", true)
	set_debug_feature("draw_collision_shapes", true)
	set_debug_feature("draw_raycasts", true)
	set_debug_feature("draw_velocity_vectors", true)
	set_debug_feature("draw_state_info", true)
	set_debug_feature("draw_hitboxes", true)

# Disable all debug features (useful for "Hide All" button)
func disable_all_physics_debug() -> void:
	set_debug_feature("native_collision_shapes", false)
	set_debug_feature("draw_collision_shapes", false)
	set_debug_feature("draw_raycasts", false)
	set_debug_feature("draw_velocity_vectors", false)
	set_debug_feature("draw_state_info", false)
	set_debug_feature("draw_hitboxes", false)

# Enable all level debug features
func enable_all_level_debug() -> void:
	set_debug_feature("draw_level_transitions", true)
	set_debug_feature("draw_spawn_points", true)
	set_debug_feature("draw_interactive_areas", true)
	set_debug_feature("draw_camera_dead_zones", true)
	set_debug_feature("draw_viewport_edges", true)

# Disable all level debug features
func disable_all_level_debug() -> void:
	set_debug_feature("draw_level_transitions", false)
	set_debug_feature("draw_spawn_points", false)
	set_debug_feature("draw_interactive_areas", false)
	set_debug_feature("draw_camera_dead_zones", false)
	set_debug_feature("draw_viewport_edges", false)

# UI Settings Management
func set_ui_font_size(size: int) -> void:
	var clamped_size = clampi(size, MIN_FONT_SIZE, MAX_FONT_SIZE)
	if ui_font_size != clamped_size:
		ui_font_size = clamped_size
		ui_settings_changed.emit(ui_font_size, ui_position)
		save_ui_settings()

func increase_font_size() -> void:
	set_ui_font_size(ui_font_size + 2)

func decrease_font_size() -> void:
	set_ui_font_size(ui_font_size - 2)

func set_ui_position(pos: Vector2) -> void:
	if ui_position != pos:
		ui_position = pos
		ui_settings_changed.emit(ui_font_size, ui_position)
		save_ui_settings()

func reset_ui_position() -> void:
	set_ui_position(DEFAULT_POSITION)

func set_ui_minimized(minimized: bool) -> void:
	if ui_minimized != minimized:
		ui_minimized = minimized
		ui_panel_state_changed.emit(ui_minimized, ui_size)
		save_ui_settings()

func set_ui_size(new_size: Vector2) -> void:
	if ui_size != new_size:
		ui_size = new_size
		ui_panel_state_changed.emit(ui_minimized, ui_size)
		save_ui_settings()

# Persistence
func save_ui_settings() -> void:
	var config = {
		"font_size": ui_font_size,
		"position": {"x": ui_position.x, "y": ui_position.y},
		"minimized": ui_minimized,
		"size": {"x": ui_size.x, "y": ui_size.y},
	}

	var file = FileAccess.open(UI_CONFIG_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(config, "\t"))
		file.close()

func load_ui_settings() -> void:
	if not FileAccess.file_exists(UI_CONFIG_PATH):
		return

	var file = FileAccess.open(UI_CONFIG_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()

		var json = JSON.new()
		var parse_result = json.parse(json_string)

		if parse_result == OK:
			var config = json.data
			if config.has("font_size"):
				ui_font_size = clampi(config.font_size, MIN_FONT_SIZE, MAX_FONT_SIZE)
			if config.has("position"):
				ui_position = Vector2(config.position.x, config.position.y)
			if config.has("minimized"):
				ui_minimized = bool(config.minimized)
			if config.has("size"):
				ui_size = Vector2(config.size.x, config.size.y)
			else:
				ui_size = DEFAULT_SIZE

			# Emit signal to update UI (will be connected after ready)
			ui_settings_changed.emit(ui_font_size, ui_position)
			ui_panel_state_changed.emit(ui_minimized, ui_size)
