extends Node

@export var is_developer_mode: bool = false
@export var manual_time_of_day: TimeManager.TimeOfDay = TimeManager.TimeOfDay.EVENING
@export var pause_time_progression: bool = true
@export var use_manual_colors: bool = true

var debug_label: Label
var debug_panel: Control

func _ready():
	create_debug_ui()

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

func create_debug_ui():
	# Create a CanvasLayer to ensure the debug UI renders on top
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # High layer value to render on top
	get_tree().current_scene.add_child(canvas_layer)
	
	debug_panel = Control.new()
	debug_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	debug_panel.position = Vector2(10, 10)
	debug_panel.size = Vector2(400, 200)
	debug_panel.visible = false
	
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.8)  # Slightly more opaque
	background.size = debug_panel.size
	debug_panel.add_child(background)
	
	debug_label = Label.new()
	debug_label.position = Vector2(10, 10)
	debug_label.size = Vector2(380, 180)
	debug_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	debug_panel.add_child(debug_label)
	
	canvas_layer.add_child(debug_panel)

func _process(_delta):
	if is_developer_mode and debug_panel:
		update_debug_display()

func update_debug_display():
	if not debug_label:
		return
		
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if not time_manager:
		debug_label.text = "Time Manager not found!"
		return
	
	var time_name = TimeManager.TimeOfDay.keys()[manual_time_of_day if pause_time_progression else time_manager.time_of_day]
	var game_time_formatted = "%.2f" % time_manager.game_time
	var period_duration = time_manager.time_period_duration
	var current_period_progress = 0.0
	
	if period_duration > 0:
		current_period_progress = (fmod(time_manager.game_time, period_duration) / period_duration) * 100.0
	
	debug_label.text = """TIME DEBUG INFO:
Current Time: %s
Game Time: %s seconds
Period Duration: %.1f seconds
Period Progress: %.1f%%
Time Progression: %s
Color Mode: %s

CONTROLS:
F12 - Toggle Dev Mode
T - Cycle Time of Day
P - Toggle Time Progression
C - Toggle Color Mode
1-6 - Set specific time
""" % [time_name, game_time_formatted, period_duration, current_period_progress, "PAUSED" if pause_time_progression else "RUNNING", "MANUAL" if use_manual_colors else "AUTOMATIC"]

func toggle_developer_mode():
	is_developer_mode = !is_developer_mode
	if debug_panel:
		debug_panel.visible = is_developer_mode
	print("Developer mode: ", "ENABLED" if is_developer_mode else "DISABLED")
	print_debug_controls()

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

func print_debug_controls():
	if is_developer_mode:
		print("=== TIME DEBUG CONTROLS ===")
		print("F12 - Toggle Developer Mode")
		print("T - Cycle Time of Day")
		print("P - Toggle Time Progression")
		print("C - Toggle Color Mode (Manual/Automatic)")
		print("1 - Morning | 2 - Mid-Morning | 3 - Noon")
		print("4 - Afternoon | 5 - Evening | 6 - Night")
		print("============================")
