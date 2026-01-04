class_name InteractiveArea2D
extends Area2D

signal interacted
signal interaction_available
signal interaction_unavailable

@export var interact_input_action = "interact"
@onready var debug_draw_manager = get_node_or_null("/root/DebugDrawManager")


func _ready():
	set_process_unhandled_input(false)
	set_notify_transform(true)


func _unhandled_input(event):
	if event.is_action_pressed(interact_input_action):
		interacted.emit()
		get_viewport().set_input_as_handled()


func _on_area_entered(area):
	set_process_unhandled_input(true)
	print(area.name)
	
	var p = area.get_parent()
	print(p.name)
	interaction_available.emit()


func _on_area_exited(area):
	set_process_unhandled_input(false)
	print(area.name)
	var p = area.get_parent()
	print(p.name)
	interaction_unavailable.emit()

func _draw():
	if not DeveloperMode.is_developer_mode:
		return
	if not debug_draw_manager:
		return
	if not debug_draw_manager.draw_interactive_areas:
		return

	# Note: Collision shapes are now visualized using Godot's native debug_collisions_hint
	# Enable via DebugDrawManager.set_debug_feature("native_collision_shapes", true)

	# Draw "[E] Interact" prompt when interaction available
	if is_processing_unhandled_input():
		var font = ThemeDB.fallback_font
		var label_text = "[E] Interact"
		var font_size = 16

		# Draw background
		var text_size = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var bg_rect = Rect2(Vector2(-text_size.x / 2 - 4, -40), text_size + Vector2(8, 4))
		draw_rect(bg_rect, debug_draw_manager.get_debug_color("label_background"), true)

		# Draw text
		draw_string(font, Vector2(-text_size.x / 2, -32), label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.YELLOW)

func _process(_delta):
	# Trigger redraw if debug enabled
	if DeveloperMode.is_developer_mode and debug_draw_manager and debug_draw_manager.draw_interactive_areas:
		queue_redraw()
