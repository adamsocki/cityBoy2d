extends Node

signal time_of_day_changed(new_time: TimeOfDay)
signal day_night_cycle_complete()

enum TimeOfDay
{
	MORNING,
	MIDMORNING,
	NOON,
	AFTERNOON,
	EVENING,
	NIGHT,
}

var game_time: float = 0.0
var time_of_day: TimeOfDay = TimeOfDay.EVENING
var time_period_duration: float = 10.0  # Default 10 seconds per time period
var time_progression_enabled: bool = true
var time_speed: float = 1.0

func _ready():
	add_to_group("time_manager")
	# Initialize to evening as per existing setup
	time_of_day = TimeOfDay.EVENING

func _process(delta):
	if time_progression_enabled:
		update_time_manager(delta * time_speed)

func update_time_manager(delta):
	# Check if developer mode has paused time progression
	var dev_mode = get_tree().get_first_node_in_group("developer_mode")
	if dev_mode and dev_mode.has_method("is_developer_mode") and dev_mode.is_developer_mode:
		if dev_mode.has_method("pause_time_progression") and dev_mode.pause_time_progression:
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

		# Check if we completed a full day cycle
		if time_of_day == TimeOfDay.MORNING and old_time == TimeOfDay.NIGHT:
			day_night_cycle_complete.emit()

# Developer mode interface methods
func set_time_of_day(new_time: TimeOfDay):
	if new_time != time_of_day:
		var old_time = time_of_day
		time_of_day = new_time
		# Adjust game_time to match the new time_of_day
		game_time = float(new_time) * time_period_duration
		time_of_day_changed.emit(time_of_day)

func get_time_of_day() -> TimeOfDay:
	return time_of_day

func set_time_progression_enabled(enabled: bool):
	time_progression_enabled = enabled

func is_time_progression_enabled() -> bool:
	return time_progression_enabled

func set_time_speed(speed: float):
	time_speed = max(0.1, speed)  # Minimum speed to prevent issues

func get_time_speed() -> float:
	return time_speed

func set_time_period_duration(duration: float):
	time_period_duration = max(1.0, duration)  # Minimum 1 second per period

func get_time_period_duration() -> float:
	return time_period_duration

func get_game_time() -> float:
	return game_time

func get_time_progress_in_current_period() -> float:
	return fmod(game_time, time_period_duration) / time_period_duration

func reset_time():
	game_time = 0.0
	time_of_day = TimeOfDay.MORNING
	time_of_day_changed.emit(time_of_day)

# Utility methods for time-based systems
func is_day_time() -> bool:
	return time_of_day in [TimeOfDay.MORNING, TimeOfDay.MIDMORNING, TimeOfDay.NOON, TimeOfDay.AFTERNOON]

func is_night_time() -> bool:
	return time_of_day in [TimeOfDay.EVENING, TimeOfDay.NIGHT]

func get_time_of_day_name() -> String:
	return TimeOfDay.keys()[time_of_day]
