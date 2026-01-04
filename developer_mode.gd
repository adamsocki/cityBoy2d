extends Node

@export var is_developer_mode: bool = false

# Legacy variables (kept for backward compatibility)
@export var manual_time_of_day: TimeManager.TimeOfDay = TimeManager.TimeOfDay.EVENING
@export var pause_time_progression: bool = true
@export var use_manual_colors: bool = true

var debug_panel_scene = preload("res://ui/debug/debug_panel.tscn")
var debug_panel_instance: Control = null
var canvas_layer: CanvasLayer = null

func _ready():
	add_to_group("developer_mode")
	pass  # Debug UI created on demand when toggled

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F12:
			toggle_developer_mode()
		elif is_developer_mode and event.keycode == KEY_T:
			cycle_time_of_day()
		elif is_developer_mode and event.keycode == KEY_P:
			toggle_time_progression()
		elif is_developer_mode and event.keycode == KEY_C:
			toggle_manual_colors()
		elif is_developer_mode and event.keycode == KEY_1:
			set_time_of_day(TimeManager.TimeOfDay.MORNING)
		elif is_developer_mode and event.keycode == KEY_2:
			set_time_of_day(TimeManager.TimeOfDay.MIDMORNING)
		elif is_developer_mode and event.keycode == KEY_3:
			set_time_of_day(TimeManager.TimeOfDay.NOON)
		elif is_developer_mode and event.keycode == KEY_4:
			set_time_of_day(TimeManager.TimeOfDay.AFTERNOON)
		elif is_developer_mode and event.keycode == KEY_5:
			set_time_of_day(TimeManager.TimeOfDay.EVENING)
		elif is_developer_mode and event.keycode == KEY_6:
			set_time_of_day(TimeManager.TimeOfDay.NIGHT)

func _show_debug_panel():
	if not debug_panel_instance:
		# Create canvas layer for UI
		canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 100
		get_tree().current_scene.add_child(canvas_layer)

		debug_panel_instance = debug_panel_scene.instantiate()
		canvas_layer.add_child(debug_panel_instance)

	debug_panel_instance.visible = true

func _hide_debug_panel():
	if debug_panel_instance:
		debug_panel_instance.visible = false

func toggle_developer_mode():
	is_developer_mode = !is_developer_mode

	if is_developer_mode:
		_show_debug_panel()
		# Enable native collision shapes for easier debugging
		get_tree().debug_collisions_hint = true
		# Sync with DebugDrawManager
		var debug_mgr = get_node_or_null("/root/DebugDrawManager")
		if debug_mgr:
			debug_mgr.native_collision_shapes = true
	else:
		_hide_debug_panel()
		# Disable native collision shapes
		get_tree().debug_collisions_hint = false
		# Sync with DebugDrawManager
		var debug_mgr = get_node_or_null("/root/DebugDrawManager")
		if debug_mgr:
			debug_mgr.native_collision_shapes = false

	print("Developer mode: ", "ENABLED" if is_developer_mode else "DISABLED")

func is_dev_mode() -> bool:
	return is_developer_mode

func cycle_time_of_day():
	var times = [
		TimeManager.TimeOfDay.MORNING,
		TimeManager.TimeOfDay.MIDMORNING, 
		TimeManager.TimeOfDay.NOON,
		TimeManager.TimeOfDay.AFTERNOON,
		TimeManager.TimeOfDay.EVENING,
		TimeManager.TimeOfDay.NIGHT
	]
	var current_index = times.find(manual_time_of_day)
	manual_time_of_day = times[(current_index + 1) % times.size()]
	print("Manual time of day: ", TimeManager.TimeOfDay.keys()[manual_time_of_day])
	
	# Trigger sky color change
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if time_manager:
		time_manager.time_of_day_changed.emit(manual_time_of_day)

func set_time_of_day(new_time: TimeManager.TimeOfDay):
	if not is_developer_mode:
		return
		
	manual_time_of_day = new_time
	print("Time of day set to: ", TimeManager.TimeOfDay.keys()[manual_time_of_day])
	
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if time_manager:
		time_manager.time_of_day_changed.emit(manual_time_of_day)

func toggle_time_progression():
	pause_time_progression = !pause_time_progression
	print("Time progression: ", "PAUSED" if pause_time_progression else "RUNNING")

func toggle_manual_colors():
	use_manual_colors = !use_manual_colors
	print("Color mode: ", "MANUAL" if use_manual_colors else "AUTOMATIC")
	
	# Trigger immediate color update
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if time_manager:
		var time_to_emit = manual_time_of_day if use_manual_colors else time_manager.time_of_day
		time_manager.time_of_day_changed.emit(time_to_emit)

func get_manual_normalized_time() -> float:
	if debug_panel_instance and debug_panel_instance.has_method("get_manual_normalized_time"):
		return debug_panel_instance.get_manual_normalized_time()
	# Fallback: convert legacy manual_time_of_day to normalized
	return float(manual_time_of_day) / 6.0

# Legacy compatibility - now delegates to panel
func is_time_progression_paused() -> bool:
	if debug_panel_instance and debug_panel_instance.has_method("is_time_paused"):
		return debug_panel_instance.is_time_paused()
	return pause_time_progression
