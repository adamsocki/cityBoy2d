class_name DebugConfig
extends Node

# Debug Configuration Constants
# Centralized configuration for debug visualization styling

# Color Scheme - Semantic colors for different debug element types
const COLORS = {
	# Navigation/Spawning
	SPAWN_POINT = Color(0.2, 1.0, 0.2, 0.6),      # Bright green
	SPAWN_CHECKPOINT = Color(1.0, 0.8, 0.2, 0.6),  # Yellow

	# Transitions/Triggers
	LEVEL_TRANSITION = Color(0.2, 0.5, 1.0, 0.4),  # Blue
	INTERACTIVE_AREA = Color(0.7, 0.2, 1.0, 0.4),  # Purple

	# Physics/Collisions
	COLLISION_SHAPE = Color(1.0, 0.2, 0.2, 0.5),   # Red
	RAYCAST = Color(1.0, 0.5, 0.0, 0.7),           # Orange
	RAYCAST_HIT = Color(0.2, 1.0, 0.2, 0.8),       # Green
	RAYCAST_MISS = Color(1.0, 0.2, 0.2, 0.7),      # Red

	# Movement
	VELOCITY_VECTOR = Color(0.0, 1.0, 1.0, 0.8),   # Cyan

	# Camera/View
	DEAD_ZONE = Color(1.0, 0.0, 0.0, 0.2),         # Transparent red

	# Text/Labels
	LABEL_TEXT = Color(1.0, 1.0, 1.0, 1.0),        # White
	LABEL_BACKGROUND = Color(0.0, 0.0, 0.0, 0.7),  # Semi-transparent black
}

# Line width constants
const LINE_WIDTH_THIN = 1.0
const LINE_WIDTH_DEFAULT = 2.0
const LINE_WIDTH_THICK = 3.0

# Font size constants
const FONT_SIZE_SMALL = 12
const FONT_SIZE_DEFAULT = 14
const FONT_SIZE_LARGE = 16

# Drawing constants
const LABEL_PADDING = 4.0  # Padding around text labels
const ARROW_HEAD_SIZE = 8.0  # Size of arrow heads for direction indicators

# =============================================================================
# UI Theme Configuration - Dark theme for debug panel
# =============================================================================

const UI_COLORS = {
	# Backgrounds
	"panel_bg": Color(0.12, 0.12, 0.14, 0.95),
	"section_bg": Color(0.16, 0.16, 0.18, 1.0),
	"section_header_bg": Color(0.18, 0.18, 0.20, 1.0),
	"section_header_hover": Color(0.22, 0.22, 0.24, 1.0),
	"tab_bg": Color(0.14, 0.14, 0.16, 1.0),
	"tab_bg_active": Color(0.20, 0.20, 0.22, 1.0),
	"title_bar_bg": Color(0.10, 0.10, 0.12, 1.0),

	# Borders
	"border": Color(0.30, 0.30, 0.35, 1.0),
	"border_accent": Color(0.40, 0.60, 0.90, 1.0),

	# Text
	"text_primary": Color(0.95, 0.95, 0.95, 1.0),
	"text_secondary": Color(0.70, 0.70, 0.75, 1.0),
	"text_value": Color(0.50, 0.90, 0.70, 1.0),
	"text_header": Color(0.90, 0.90, 0.95, 1.0),
	"text_muted": Color(0.50, 0.50, 0.55, 1.0),

	# Buttons
	"button_normal": Color(0.22, 0.22, 0.25, 1.0),
	"button_hover": Color(0.28, 0.28, 0.32, 1.0),
	"button_pressed": Color(0.18, 0.18, 0.20, 1.0),
	"button_disabled": Color(0.16, 0.16, 0.18, 1.0),

	# Sliders
	"slider_bg": Color(0.18, 0.18, 0.20, 1.0),
	"slider_fill": Color(0.35, 0.55, 0.80, 1.0),
	"slider_grabber": Color(0.50, 0.70, 0.95, 1.0),

	# Check buttons
	"check_off": Color(0.25, 0.25, 0.28, 1.0),
	"check_on": Color(0.35, 0.65, 0.50, 1.0),

	# Separators
	"separator": Color(0.35, 0.35, 0.40, 0.6),

	# Resize handle
	"resize_handle": Color(0.40, 0.40, 0.45, 0.8),
}

const UI_FONTS = {
	"default_size": 14,
	"header_size": 16,
	"title_size": 18,
	"small_size": 12,
}

const UI_SPACING = {
	"panel_margin": 12,
	"section_margin": 8,
	"item_spacing": 6,
	"section_spacing": 10,
}

const UI_SIZES = {
	"title_bar_height": 36,
	"minimized_height": 32,
	"min_panel_width": 320,
	"min_panel_height": 250,
	"max_panel_width": 800,
	"max_panel_height": 900,
	"default_panel_width": 400,
	"default_panel_height": 500,
	"resize_margin": 8,
	"corner_radius": 4,
	"section_corner_radius": 3,
}
