extends Node

signal time_of_day_changed(new_time: TimeOfDay)
signal day_night_cycle_complete()
signal continuous_time_changed(normalized_time: float)
signal distance_contribution_updated(distance: float, contribution: float)

enum TimeOfDay
{
	MORNING,
	MIDMORNING,
	NOON,
	AFTERNOON,
	EVENING,
	NIGHT,
}

# Legacy discrete time system (kept for backward compatibility)
var game_time: float = 0.0
var time_of_day: TimeOfDay = TimeOfDay.EVENING
var time_period_duration: float = 1.0  # Default 10 seconds per time period
var time_progression_enabled: bool = true
var time_speed: float = 1.0

# NEW CONTINUOUS TIME SYSTEM
var normalized_time: float = 0.0  # 0.0 to 1.0, represents full day cycle
var total_distance_traveled: float = 0.0

# Configuration for hybrid progression
@export var distance_contribution_factor: float = 0.3  # How much distance affects time
@export var time_contribution_factor: float = 0.7     # How much real-time affects time
@export var distance_per_full_cycle: float = 10000.0  # Distance needed for full day (pixels)
@export var seconds_per_full_cycle: float = 600.0     # Default: 10 minutes for full cycle
@export var start_time_normalized: float = 0.667      # Start at EVENING (0.667 = 4/6)

# Signal emission throttling
var last_signal_normalized_time: float = 0.0
var signal_emission_threshold: float = 0.005  # Emit signal every 0.5% progress

func _ready():
	add_to_group("time_manager")
	# Initialize to evening as per existing setup
	time_of_day = TimeOfDay.EVENING
	normalized_time = start_time_normalized

	# Connect to player distance tracking
	call_deferred("_connect_to_player")

func _process(delta):
	if time_progression_enabled:
		update_time_manager(delta * time_speed)

func update_time_manager(delta):
	# Check if developer mode has paused time progression
	var dev_mode = get_tree().get_first_node_in_group("developer_mode")
	if dev_mode and dev_mode.is_developer_mode:
		if dev_mode.has_method("is_time_progression_paused"):
			if dev_mode.is_time_progression_paused():
				return
		elif dev_mode.pause_time_progression:
			return

	# Calculate time-based contribution
	var time_delta = (delta / seconds_per_full_cycle) * time_contribution_factor

	# Update normalized time
	var old_normalized_time = normalized_time
	normalized_time += time_delta

	# Wrap around (0.0 to 1.0)
	if normalized_time >= 1.0:
		normalized_time = fmod(normalized_time, 1.0)
		day_night_cycle_complete.emit()

	# Update legacy game_time for save compatibility
	game_time += delta

	# Emit continuous signal if threshold crossed
	if abs(normalized_time - last_signal_normalized_time) >= signal_emission_threshold:
		continuous_time_changed.emit(normalized_time)
		last_signal_normalized_time = normalized_time

	# Emit discrete signals for backward compatibility
	_check_and_emit_discrete_time_changes(old_normalized_time, normalized_time)

# Player connection and distance tracking
func _connect_to_player():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("distance_traveled"):
		player.distance_traveled.connect(_on_player_distance_traveled)
		print("TimeManager: Connected to player distance tracking")
	else:
		print("TimeManager: Player not found or no distance_traveled signal - using time-only progression")

func _on_player_distance_traveled(distance_delta: float):
	total_distance_traveled += distance_delta

	# Calculate distance-based contribution
	var distance_contribution = (distance_delta / distance_per_full_cycle) * distance_contribution_factor

	var old_normalized_time = normalized_time
	normalized_time += distance_contribution

	# Wrap around
	if normalized_time >= 1.0:
		normalized_time = fmod(normalized_time, 1.0)
		day_night_cycle_complete.emit()

	# Emit signals
	distance_contribution_updated.emit(distance_delta, distance_contribution)

	if abs(normalized_time - last_signal_normalized_time) >= signal_emission_threshold:
		continuous_time_changed.emit(normalized_time)
		last_signal_normalized_time = normalized_time

	_check_and_emit_discrete_time_changes(old_normalized_time, normalized_time)

# Discrete compatibility layer
func _check_and_emit_discrete_time_changes(old_time: float, new_time: float):
	# Map normalized time to discrete periods (for backward compatibility)
	var old_period = _get_period_from_normalized(old_time)
	var new_period = _get_period_from_normalized(new_time)

	if old_period != new_period:
		time_of_day = new_period
		time_of_day_changed.emit(time_of_day)

func _get_period_from_normalized(norm_time: float) -> TimeOfDay:
	var period_index = int(norm_time * 6.0) % 6
	return period_index as TimeOfDay

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

# NEW PUBLIC API for continuous time system
func get_normalized_time() -> float:
	return normalized_time

func set_normalized_time(new_time: float):
	normalized_time = clamp(new_time, 0.0, 0.9999)
	continuous_time_changed.emit(normalized_time)
	var new_period = _get_period_from_normalized(normalized_time)
	if new_period != time_of_day:
		time_of_day = new_period
		time_of_day_changed.emit(time_of_day)

func get_time_of_day_from_normalized(norm_time: float) -> String:
	var waypoints = ["MORNING", "MIDMORNING", "NOON", "AFTERNOON", "EVENING", "NIGHT"]
	var index = int(norm_time * 6.0) % 6
	return waypoints[index]

func set_start_time(norm_time: float):
	start_time_normalized = clamp(norm_time, 0.0, 0.9999)
	normalized_time = start_time_normalized

func set_progression_factors(distance_factor: float, time_factor: float):
	# Normalize to sum to 1.0
	var total = distance_factor + time_factor
	if total > 0:
		distance_contribution_factor = distance_factor / total
		time_contribution_factor = time_factor / total

func get_distance_traveled() -> float:
	return total_distance_traveled

func reset_distance():
	total_distance_traveled = 0.0
