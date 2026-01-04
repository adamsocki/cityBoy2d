extends Camera2D

# Camera follow properties
@export var target_path: NodePath
@export var follow_speed: float = 5.0
@export var look_ahead_factor: float = 0.2

# Dead zone properties
@export var use_dead_zone: bool = true
@export var dead_zone_width: float = 200  # Width of dead zone in pixels
@export var dead_zone_height: float = 100  # Height of dead zone in pixels

# Screen shake properties
var shake_amount: float = 0
var shake_duration: float = 0
var default_offset: Vector2 = offset

# Target node reference
var target: Node2D
var dead_zone_rect: Rect2
@onready var debug_draw_manager = get_node_or_null("/root/DebugDrawManager")

func _ready() -> void:
	if target_path:
		target = get_node(target_path)
		global_position = target.global_position
	
	update_dead_zone()

func update_dead_zone() -> void:
	var screen_size = get_viewport_rect().size
	var center = screen_size / 2
	
	dead_zone_rect.position = get_parent().global_position
	dead_zone_rect.position.x -= dead_zone_width  / 2
	dead_zone_rect.position.y -= dead_zone_height / 2
	
	dead_zone_rect.size = Vector2(dead_zone_width,dead_zone_height)

func _process(delta):
	#print("camera Position", get_transform())
	#print("target transform", target.get_transform())
	#print("target get global transform with cangvas", target.get_global_transform_with_canvas())
	#print("get_viewport_rect().size.x", get_viewport_rect().size.x)
	
	if !target:
		return
		
	# Get the target's position relative to the camera's viewport
	var target_pos = target.get_global_position()
	#var camera_pos = global_position
	var camera_pos = global_position
	var new_camera_pos = camera_pos
	
	# Convert target position to camera's local coordinates
	var target_local_pos = target_pos - camera_pos
	
	if abs(target_local_pos.x) > dead_zone_width / 2:
		var offset_x = target_local_pos.x - (sign(target_local_pos.x) * dead_zone_width / 2)
		new_camera_pos.x = camera_pos.x + offset_x
	
	if abs(target_local_pos.y) > dead_zone_height / 2:
		var offset_y = target_local_pos.y - (sign(target_local_pos.y) * dead_zone_height / 2)
		new_camera_pos.y = camera_pos.y + offset_y
	
	if new_camera_pos != camera_pos:
		global_position = global_position.lerp(new_camera_pos, follow_speed * delta)

	# Trigger redraw if debug enabled
	if DeveloperMode.is_developer_mode and debug_draw_manager and debug_draw_manager.draw_camera_dead_zones:
		queue_redraw()

func _physics_process(delta: float) -> void:
	if not target:
		return

# Debug draw to visualize dead zone
func _draw() -> void:
	if not DeveloperMode.is_developer_mode:
		return
	if not debug_draw_manager:
		return
	if not debug_draw_manager.draw_camera_dead_zones:
		return
	if not use_dead_zone:
		return

	var color = debug_draw_manager.get_debug_color("dead_zone")
	var line_width = debug_draw_manager.get_line_width("default")

	# Draw filled dead zone
	draw_rect(dead_zone_rect, color, true)

	# Draw outline for better visibility
	draw_rect(dead_zone_rect, Color.RED, false, line_width)

	# Draw label
	var font = ThemeDB.fallback_font
	var font_size = 12
	var label_text = "Camera Dead Zone"
	var text_size = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var label_pos = dead_zone_rect.position + Vector2(dead_zone_rect.size.x / 2 - text_size.x / 2, -8)

	# Background for text
	var bg_rect = Rect2(label_pos - Vector2(4, font_size), text_size + Vector2(8, 4))
	draw_rect(bg_rect, debug_draw_manager.get_debug_color("label_background"), true)

	# Text
	draw_string(font, label_pos, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size,
		debug_draw_manager.get_debug_color("label_text"))

# Function to trigger screen shake
func shake(amount: float, duration: float) -> void:
	shake_amount = amount
	shake_duration = duration
