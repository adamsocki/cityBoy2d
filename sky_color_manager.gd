extends CanvasLayer

@export var parallax_scene: Node2D
@export var sky_transition_duration: float = 2.0  # Increased for smoother transitions

var sky_color_rect: ColorRect
var tween: Tween
var current_target_color: Color

# Legacy discrete color map (kept for backward compatibility)
@export var sky_colors_per_time_of_day = {
	TimeManager.TimeOfDay.MORNING: Color.WHITE,
	TimeManager.TimeOfDay.MIDMORNING: Color(1.0, 0.95, 0.8),     # Warm white
	TimeManager.TimeOfDay.NOON: Color(0.9, 0.95, 1.0),           # Bright blue-white
	TimeManager.TimeOfDay.AFTERNOON: Color(1.0, 0.9, 0.7),       # Golden
	TimeManager.TimeOfDay.EVENING: Color(1.0, 0.6, 0.4),         # Orange/pink
	TimeManager.TimeOfDay.NIGHT: Color(0.3, 0.3, 0.6),           # Dark blue
}

# Color waypoints at normalized positions for smooth interpolation
var color_waypoints = [
	{"position": 0.0,    "color": Color.WHITE},                    # MORNING
	{"position": 0.167,  "color": Color(1.0, 0.95, 0.8)},         # MIDMORNING
	{"position": 0.333,  "color": Color(0.9, 0.95, 1.0)},         # NOON
	{"position": 0.5,    "color": Color(1.0, 0.9, 0.7)},          # AFTERNOON
	{"position": 0.667,  "color": Color(1.0, 0.6, 0.4)},          # EVENING
	{"position": 0.833,  "color": Color(0.3, 0.3, 0.6)},          # NIGHT
]

func _ready():
	add_to_group("sky_color_manager")
	if parallax_scene:
		sky_color_rect = parallax_scene.get_node("Level1_Parallax/ParallaxLayer/SkyColor")
	else:
		print("Error: parallax_scene is null in sky_color_manager")

	# Connect to the TimeManager singleton - continuous signal for smooth transitions
	if TimeManager:
		TimeManager.continuous_time_changed.connect(_on_continuous_time_changed)
		# Set initial color based on current time
		_on_continuous_time_changed(TimeManager.get_normalized_time())

	# Keep legacy signal for backward compatibility
	if TimeManager:
		TimeManager.time_of_day_changed.connect(_on_time_manager_time_of_day_changed)

func init_me():
	# Legacy function kept for compatibility but now calls _ready functionality
	if not sky_color_rect and parallax_scene:
		sky_color_rect = parallax_scene.get_node("Level1_Parallax/ParallaxLayer/SkyColor")
	
func update_color_sky_change_manager(delta):
	pass

# NEW: Continuous time interpolation
func _on_continuous_time_changed(normalized_time: float):
	if not sky_color_rect:
		return

	# Check developer mode override
	var dev_mode = get_tree().get_first_node_in_group("developer_mode")
	if dev_mode and dev_mode.is_developer_mode and dev_mode.use_manual_colors:
		# Use manual time for color calculation
		if dev_mode.has_method("get_manual_normalized_time"):
			normalized_time = dev_mode.get_manual_normalized_time()
		else:
			# Fallback: convert manual discrete time to normalized
			normalized_time = (dev_mode.manual_time_of_day as float) / 6.0

	var target_color = _interpolate_color_from_normalized_time(normalized_time)

	# Only tween if color changed significantly
	if not current_target_color or _color_distance(current_target_color, target_color) > 0.01:
		current_target_color = target_color

		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(sky_color_rect, "color", target_color, sky_transition_duration)

func _color_distance(a: Color, b: Color) -> float:
	var dr = abs(a.r - b.r)
	var dg = abs(a.g - b.g)
	var db = abs(a.b - b.b)
	var da = abs(a.a - b.a)
	return max(max(dr, dg), max(db, da))

func _interpolate_color_from_normalized_time(norm_time: float) -> Color:
	# Find two adjacent waypoints
	var prev_waypoint = color_waypoints[0]
	var next_waypoint = color_waypoints[0]

	for i in range(color_waypoints.size()):
		var waypoint = color_waypoints[i]
		if waypoint.position <= norm_time:
			prev_waypoint = waypoint
			# Next waypoint wraps around
			next_waypoint = color_waypoints[(i + 1) % color_waypoints.size()]

	# Handle wrap-around case (night to morning)
	var prev_pos = prev_waypoint.position
	var next_pos = next_waypoint.position

	if next_pos < prev_pos:  # Wrapped around
		next_pos += 1.0
		if norm_time < prev_pos:
			norm_time += 1.0

	# Calculate interpolation factor
	var range_size = next_pos - prev_pos
	var t = 0.0 if range_size == 0.0 else (norm_time - prev_pos) / range_size

	# Smooth interpolation using smoothstep for more natural transitions
	t = smoothstep(0.0, 1.0, t)

	return prev_waypoint.color.lerp(next_waypoint.color, t)

# Legacy color lookup with fallback to interpolated color.
func _get_legacy_color_for_time(time_value) -> Color:
	if time_value == null:
		return Color.WHITE
	if sky_colors_per_time_of_day is Dictionary and sky_colors_per_time_of_day.has(time_value):
		return sky_colors_per_time_of_day[time_value]
	return _interpolate_color_from_normalized_time(float(time_value) / 6.0)

# Legacy discrete signal handler (kept for backward compatibility)
func _on_time_manager_time_of_day_changed(new_time: TimeManager.TimeOfDay) -> void:
	print("_on_time_manager_time_of_day_changed in sky color manager")
	if sky_color_rect:
		print("sky_color_rect and timeManager in sky color manager")
		var dev_mode = get_tree().get_first_node_in_group("developer_mode")
		var time_to_use = new_time
		if dev_mode and dev_mode.is_developer_mode and dev_mode.use_manual_colors:
			time_to_use = dev_mode.manual_time_of_day

		var target_color = _get_legacy_color_for_time(time_to_use)

		# Create smooth color transition
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(sky_color_rect, "color", target_color, sky_transition_duration)
	pass # Replace with function body.
