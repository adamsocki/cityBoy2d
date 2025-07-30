class_name TimeManager
extends Node2D

signal time_of_day_changed(new_time: TimeOfDay)

enum TimeOfDay
{
	MORNING,
	MIDMORNING,
	NOON,
	AFTERNOON,
	EVENING,
	NIGHT,
}

var game_time: float
var time_of_day: TimeOfDay = TimeOfDay.MORNING
@export var time_period_duration: float




func init_time_manager():
	game_time = 0
	for child in get_children():
		if child.has_method("init_me"):
			child.call("init_me")


func update_time_manager(delta):
	if DeveloperMode.is_dev_mode() and DeveloperMode.pause_time_progression:
		return
		
	game_time += delta
	
	var current_period = int(game_time / time_period_duration) % TimeOfDay.size()
	if time_of_day != current_period:
		time_of_day = current_period
		print("Time of day changed to: ", TimeOfDay.keys()[time_of_day])
		time_of_day_changed.emit(time_of_day)
