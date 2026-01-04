extends Area2D

@export var next_level_scene: String = ""
@export var spawn_point: String = "default"
@export var transition_delay: float = 0.2

var player: CharacterBody2D
var is_transitioning: bool = false
@onready var debug_draw_manager = get_node_or_null("/root/DebugDrawManager")

func _ready():
	body_entered.connect(_on_player_entered)
	add_to_group("level_transitions")
	set_notify_transform(true)

func _on_player_entered(body):
	if body.name == "Player" and not is_transitioning:
		player = body
		is_transitioning = true
		transition_to_level()

func transition_to_level():
	if next_level_scene.is_empty():
		print("No next level scene specified")
		is_transitioning = false
		return

	# Small delay to prevent accidental re-triggering
	await get_tree().create_timer(transition_delay).timeout

	# Use LevelManager for transition instead of direct scene change
	LevelManager.transition_to_level(next_level_scene, spawn_point)

func _draw():
	if not DeveloperMode.is_developer_mode:
		return
	if not debug_draw_manager:
		return
	if not debug_draw_manager.draw_level_transitions:
		return

	# Note: Collision shapes are now visualized using Godot's native debug_collisions_hint
	# Enable via DebugDrawManager.set_debug_feature("native_collision_shapes", true)

	var collision_shape = get_node_or_null("CollisionShape2D")
	if not collision_shape or not collision_shape.shape:
		return

	# Determine center position based on shape type
	var center_pos = Vector2.ZERO
	if collision_shape.shape is RectangleShape2D:
		var rect_shape = collision_shape.shape as RectangleShape2D
		var rect = Rect2(
			collision_shape.position - rect_shape.size / 2,
			rect_shape.size
		)
		center_pos = rect.get_center()
	elif collision_shape.shape is CircleShape2D:
		center_pos = collision_shape.position

	# Draw arrow and label
	_draw_transition_arrow(center_pos)
	_draw_transition_label(center_pos)

func _draw_transition_arrow(center: Vector2):
	var arrow_start = center
	var arrow_end = center + Vector2(50, 0)  # Point right

	draw_line(arrow_start, arrow_end, Color.WHITE, 2.0)

	# Draw arrowhead
	var head_size = 10
	draw_line(arrow_end, arrow_end + Vector2(-head_size, -head_size), Color.WHITE, 2.0)
	draw_line(arrow_end, arrow_end + Vector2(-head_size, head_size), Color.WHITE, 2.0)

func _draw_transition_label(position: Vector2):
	if next_level_scene.is_empty():
		return

	var label_text = "→ " + next_level_scene.get_file().get_basename()
	var font = ThemeDB.fallback_font
	var font_size = 16

	# Draw background
	var text_size = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var bg_rect = Rect2(position + Vector2(-text_size.x / 2 - 4, -30), text_size + Vector2(8, 4))
	draw_rect(bg_rect, debug_draw_manager.get_debug_color("label_background"), true)

	# Draw text
	draw_string(font, position + Vector2(0, -22), label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)

func _process(_delta):
	# Trigger redraw if debug enabled
	if DeveloperMode.is_developer_mode and debug_draw_manager and debug_draw_manager.draw_level_transitions:
		queue_redraw()
