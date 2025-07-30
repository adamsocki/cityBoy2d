extends Node

@export var is_developer_mode: bool = false
@export var manual_time_of_day: TimeManager.TimeOfDay = TimeManager.TimeOfDay.EVENING
@export var pause_time_progression: bool = true

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F12:
			toggle_developer_mode()
		elif is_developer_mode and event.keycode == KEY_T:
			cycle_time_of_day()
		elif is_developer_mode and event.keycode == KEY_P:
			toggle_time_progression()

func toggle_developer_mode():
	is_developer_mode = !is_developer_mode
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
	print("Manual time of day: ", manual_time_of_day)
	
	# Trigger sky color change
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if time_manager:
		time_manager.time_of_day_changed.emit(manual_time_of_day)

func toggle_time_progression():
	pause_time_progression = !pause_time_progression
	print("Time progression: ", "PAUSED" if pause_time_progression else "RUNNING")
