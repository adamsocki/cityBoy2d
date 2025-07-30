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
	var dev_mode = get_tree().get_first_node_in_group("developer_mode")
	if dev_mode and dev_mode.is_developer_mode and dev_mode.pause_time_progression:
		return
		
	game_time += delta
	
	var current_period = int(game_time / time_period_duration) % TimeOfDay.size()
	if time_of_day != current_period:
		var old_time = time_of_day
		time_of_day = current_period
		var period_progress = (fmod(game_time, time_period_duration) / time_period_duration) * 100.0
		
		print("=== TIME OF DAY CHANGE ===")
		print("From: ", TimeOfDay.keys()[old_time], " -> To: ", TimeOfDay.keys()[time_of_day])
		print("Game Time: %.2f seconds" % game_time)
		print("Period Duration: %.1f seconds" % time_period_duration)
		print("Period Progress: %.1f%%" % period_progress)
		print("========================")
		
		time_of_day_changed.emit(time_of_day)
