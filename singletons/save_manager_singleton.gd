extends Node

signal game_saved(save_slot: int)
signal game_loaded(save_slot: int)
signal save_failed(error: String)
signal load_failed(error: String)

const SAVE_FILE_PREFIX = "user://savegame_"
const SAVE_FILE_EXTENSION = ".save"
const MAX_SAVE_SLOTS = 3

var current_save_slot: int = 0
var auto_save_enabled: bool = true
var auto_save_interval: float = 300.0  # 5 minutes
var auto_save_timer: float = 0.0

func _ready():
	add_to_group("save_manager")

func _process(delta):
	if auto_save_enabled:
		auto_save_timer += delta
		if auto_save_timer >= auto_save_interval:
			auto_save_timer = 0.0
			auto_save()

func save_game(save_slot: int = current_save_slot) -> bool:
	if save_slot < 0 or save_slot >= MAX_SAVE_SLOTS:
		save_failed.emit("Invalid save slot: " + str(save_slot))
		return false

	var save_file_path = SAVE_FILE_PREFIX + str(save_slot) + SAVE_FILE_EXTENSION
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)

	if not save_file:
		save_failed.emit("Could not open save file: " + save_file_path)
		return false

	var save_data = _collect_save_data()
	var json_string = JSON.stringify(save_data)
	save_file.store_string(json_string)
	save_file.close()

	current_save_slot = save_slot
	game_saved.emit(save_slot)
	print("Game saved to slot ", save_slot)
	return true

func load_game(save_slot: int = current_save_slot) -> bool:
	if save_slot < 0 or save_slot >= MAX_SAVE_SLOTS:
		load_failed.emit("Invalid save slot: " + str(save_slot))
		return false

	var save_file_path = SAVE_FILE_PREFIX + str(save_slot) + SAVE_FILE_EXTENSION

	if not FileAccess.file_exists(save_file_path):
		load_failed.emit("Save file does not exist: " + save_file_path)
		return false

	var save_file = FileAccess.open(save_file_path, FileAccess.READ)
	if not save_file:
		load_failed.emit("Could not open save file: " + save_file_path)
		return false

	var json_string = save_file.get_as_text()
	save_file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		load_failed.emit("Failed to parse save file JSON")
		return false

	var save_data = json.data
	_apply_save_data(save_data)

	current_save_slot = save_slot
	game_loaded.emit(save_slot)
	print("Game loaded from slot ", save_slot)
	return true

func auto_save():
	if current_save_slot >= 0:
		save_game(current_save_slot)

func _collect_save_data() -> Dictionary:
	var save_data = {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"player_data": {},
		"level_data": {},
		"time_data": {},
		"audio_settings": {},
		"game_settings": {}
	}

	# Collect player data from GameManager
	if GameManager:
		save_data.player_data = GameManager.get_player_data().duplicate()
		save_data.game_settings = GameManager.game_settings.duplicate()

	# Collect level data from LevelManager
	if LevelManager:
		save_data.level_data = {
			"current_level": LevelManager.get_current_level(),
			"completion_data": LevelManager.level_completion_data.duplicate(),
			"available_levels": LevelManager.get_available_levels().duplicate()
		}

	# Collect time data from TimeManager
	if TimeManager:
		save_data.time_data = {
			"current_time": TimeManager.get_time_of_day(),  # Keep for compatibility
			"game_time": TimeManager.get_game_time(),
			"normalized_time": TimeManager.get_normalized_time(),  # NEW
			"total_distance": TimeManager.get_distance_traveled(),  # NEW
			"time_period_duration": TimeManager.get_time_period_duration(),
			"time_progression_enabled": TimeManager.is_time_progression_enabled(),
			"time_speed": TimeManager.get_time_speed(),
			"distance_factor": TimeManager.distance_contribution_factor,  # NEW
			"time_factor": TimeManager.time_contribution_factor,  # NEW
			"seconds_per_cycle": TimeManager.seconds_per_full_cycle,  # NEW
		}

	# Collect audio settings from AudioManager
	if AudioManager:
		save_data.audio_settings = {
			"music_volume": AudioManager.get_music_volume(),
			"sfx_volume": AudioManager.get_sfx_volume(),
			"ambient_volume": AudioManager.get_ambient_volume(),
			"music_enabled": AudioManager.is_music_enabled,
			"sfx_enabled": AudioManager.is_sfx_enabled,
			"ambient_enabled": AudioManager.is_ambient_enabled,
			"current_music": AudioManager.get_current_music()
		}

	return save_data

func _apply_save_data(save_data: Dictionary):
	# Apply player data to GameManager
	if save_data.has("player_data") and GameManager:
		GameManager.player_data = save_data.player_data.duplicate()
		if save_data.has("game_settings"):
			GameManager.game_settings = save_data.game_settings.duplicate()

	# Apply level data to LevelManager
	if save_data.has("level_data") and LevelManager:
		var level_data = save_data.level_data
		LevelManager.level_completion_data = level_data.get("completion_data", {}).duplicate()
		LevelManager.available_levels = level_data.get("available_levels", ["Level1", "Level2"]).duplicate()

		# Don't automatically change levels during load - let the player decide
		# But store the saved level for reference
		if level_data.has("current_level"):
			GameManager.save_player_data({"saved_level": level_data.current_level})

	# Apply time data to TimeManager
	if save_data.has("time_data") and TimeManager:
		var time_data = save_data.time_data

		# Load normalized time if available (new save format)
		if time_data.has("normalized_time"):
			TimeManager.normalized_time = time_data.get("normalized_time", 0.667)
			TimeManager.total_distance_traveled = time_data.get("total_distance", 0.0)
			TimeManager.distance_contribution_factor = time_data.get("distance_factor", 0.3)
			TimeManager.time_contribution_factor = time_data.get("time_factor", 0.7)
			TimeManager.seconds_per_full_cycle = time_data.get("seconds_per_cycle", 600.0)
		else:
			# Fallback to discrete time for old saves
			var discrete_time = time_data.get("current_time", TimeManager.TimeOfDay.EVENING)
			TimeManager.normalized_time = (discrete_time as float) / 6.0

		TimeManager.game_time = time_data.get("game_time", 0.0)
		TimeManager.set_time_of_day(time_data.get("current_time", TimeManager.TimeOfDay.EVENING))
		TimeManager.set_time_period_duration(time_data.get("time_period_duration", 10.0))
		TimeManager.set_time_progression_enabled(time_data.get("time_progression_enabled", true))
		TimeManager.set_time_speed(time_data.get("time_speed", 1.0))

		# Emit initial signal to update visuals
		TimeManager.continuous_time_changed.emit(TimeManager.normalized_time)

	# Apply audio settings to AudioManager
	if save_data.has("audio_settings") and AudioManager:
		var audio_data = save_data.audio_settings
		AudioManager.set_music_volume(audio_data.get("music_volume", 1.0))
		AudioManager.set_sfx_volume(audio_data.get("sfx_volume", 1.0))
		AudioManager.set_ambient_volume(audio_data.get("ambient_volume", 0.5))
		AudioManager.set_music_enabled(audio_data.get("music_enabled", true))
		AudioManager.set_sfx_enabled(audio_data.get("sfx_enabled", true))
		AudioManager.set_ambient_enabled(audio_data.get("ambient_enabled", true))

func delete_save(save_slot: int) -> bool:
	if save_slot < 0 or save_slot >= MAX_SAVE_SLOTS:
		return false

	var save_file_path = SAVE_FILE_PREFIX + str(save_slot) + SAVE_FILE_EXTENSION

	if FileAccess.file_exists(save_file_path):
		DirAccess.remove_absolute(save_file_path)
		print("Deleted save file: ", save_file_path)
		return true

	return false

func save_exists(save_slot: int) -> bool:
	if save_slot < 0 or save_slot >= MAX_SAVE_SLOTS:
		return false

	var save_file_path = SAVE_FILE_PREFIX + str(save_slot) + SAVE_FILE_EXTENSION
	return FileAccess.file_exists(save_file_path)

func get_save_info(save_slot: int) -> Dictionary:
	if not save_exists(save_slot):
		return {}

	var save_file_path = SAVE_FILE_PREFIX + str(save_slot) + SAVE_FILE_EXTENSION
	var save_file = FileAccess.open(save_file_path, FileAccess.READ)

	if not save_file:
		return {}

	var json_string = save_file.get_as_text()
	save_file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		return {}

	var save_data = json.data
	return {
		"timestamp": save_data.get("timestamp", 0),
		"level": save_data.get("level_data", {}).get("current_level", "Unknown"),
		"player_health": save_data.get("player_data", {}).get("health", 0),
		"playtime": save_data.get("time_data", {}).get("game_time", 0)
	}

func get_max_save_slots() -> int:
	return MAX_SAVE_SLOTS

func set_auto_save_enabled(enabled: bool):
	auto_save_enabled = enabled
	auto_save_timer = 0.0

func set_auto_save_interval(interval: float):
	auto_save_interval = max(60.0, interval)  # Minimum 1 minute

func get_current_save_slot() -> int:
	return current_save_slot