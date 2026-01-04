class_name SpawnPoint
extends Marker2D

@export var spawn_id: String = "default"
@export var spawn_direction: int = 1  # 1 for right, -1 for left
@export var is_checkpoint: bool = false
@onready var debug_draw_manager = get_node_or_null("/root/DebugDrawManager")

func _ready():
	add_to_group("spawn_points")

	# Visual indicator in editor (will not appear in game)
	if Engine.is_editor_hint():
		_create_editor_visual()
	else:
		# Enable runtime debug drawing
		set_notify_transform(true)

func get_spawn_id() -> String:
	return spawn_id

func get_spawn_position() -> Vector2:
	return global_position

func get_spawn_direction() -> int:
	return spawn_direction

func is_spawn_checkpoint() -> bool:
	return is_checkpoint

func activate_spawn():
	"""Called when player reaches this spawn point"""
	if is_checkpoint:
		# Save this as a checkpoint
		GameManager.save_player_data({
			"checkpoint_position": global_position,
			"checkpoint_spawn_id": spawn_id,
			"checkpoint_level": LevelManager.get_current_level()
		})
		print("Checkpoint activated: ", spawn_id)

func _create_editor_visual():
	"""Creates a visual indicator for the spawn point in the editor"""
	if not Engine.is_editor_hint():
		return

	# Create a simple icon/shape to show spawn point location
	var icon = ColorRect.new()
	icon.size = Vector2(32, 32)
	icon.position = Vector2(-16, -16)  # Center the icon
	icon.color = Color.GREEN if spawn_id == "default" else Color.YELLOW
	icon.color.a = 0.7
	add_child(icon)

	# Add a label with the spawn ID
	var label = Label.new()
	label.text = spawn_id
	label.position = Vector2(-16, 20)
	label.size = Vector2(64, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)

func _draw():
	# Only draw in runtime (not editor)
	if Engine.is_editor_hint():
		return

	if not DeveloperMode.is_developer_mode:
		return
	if not debug_draw_manager:
		return
	if not debug_draw_manager.draw_spawn_points:
		return

	var color = debug_draw_manager.get_debug_color("spawn_checkpoint" if is_checkpoint else "spawn_point")

	# Draw circle at spawn position
	draw_circle(Vector2.ZERO, 20, color)
	draw_arc(Vector2.ZERO, 20, 0, TAU, 32, Color.WHITE, 2.0)

	# Draw direction indicator
	var direction_vec = Vector2(spawn_direction * 30, 0)
	draw_line(Vector2.ZERO, direction_vec, Color.WHITE, 3.0)

	# Draw arrowhead for direction
	var arrow_angle = 0 if spawn_direction > 0 else PI
	var head_size = 8
	draw_line(
		direction_vec,
		direction_vec + Vector2(cos(arrow_angle + 2.5), sin(arrow_angle + 2.5)) * head_size,
		Color.WHITE, 3.0
	)
	draw_line(
		direction_vec,
		direction_vec + Vector2(cos(arrow_angle - 2.5), sin(arrow_angle - 2.5)) * head_size,
		Color.WHITE, 3.0
	)

	# Draw label
	var font = ThemeDB.fallback_font
	var label_text = spawn_id + (" [CP]" if is_checkpoint else "")
	var font_size = 14

	# Draw background
	var text_size = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var bg_rect = Rect2(Vector2(-text_size.x / 2 - 4, -40), text_size + Vector2(8, 4))
	draw_rect(bg_rect, debug_draw_manager.get_debug_color("label_background"), true)

	# Draw text
	draw_string(font, Vector2(-text_size.x / 2, -32), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

func _process(_delta):
	# Only in runtime
	if Engine.is_editor_hint():
		return

	# Trigger redraw if debug enabled
	if DeveloperMode.is_developer_mode and debug_draw_manager and debug_draw_manager.draw_spawn_points:
		queue_redraw()
