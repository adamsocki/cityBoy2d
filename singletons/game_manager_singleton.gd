extends Node

signal game_paused(is_paused: bool)
signal player_health_changed(new_health: int)
signal player_data_updated(data: Dictionary)

var is_game_paused: bool = false
var player_data = {
	"health": 100,
	"max_health": 100,
	"items": [],
	"current_level": "Level1",
	"checkpoint_position": Vector2.ZERO,
	"coins": 0,
	"experience": 0
}

var game_settings = {
	"developer_mode": false,
	"sound_volume": 1.0,
	"music_volume": 1.0
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("game_manager")

func _input(event):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func toggle_pause():
	is_game_paused = !is_game_paused
	get_tree().paused = is_game_paused
	game_paused.emit(is_game_paused)

func pause_game():
	if not is_game_paused:
		toggle_pause()

func unpause_game():
	if is_game_paused:
		toggle_pause()

func save_player_data(data: Dictionary):
	player_data.merge(data)
	player_data_updated.emit(player_data)

func get_player_data() -> Dictionary:
	return player_data

func update_player_health(new_health: int):
	player_data.health = clamp(new_health, 0, player_data.max_health)
	player_health_changed.emit(player_data.health)

func add_player_item(item: String):
	if not player_data.items.has(item):
		player_data.items.append(item)
		player_data_updated.emit(player_data)

func remove_player_item(item: String):
	if player_data.items.has(item):
		player_data.items.erase(item)
		player_data_updated.emit(player_data)

func reset_player_data():
	player_data = {
		"health": 100,
		"max_health": 100,
		"items": [],
		"current_level": "Level1",
		"checkpoint_position": Vector2.ZERO,
		"coins": 0,
		"experience": 0
	}
	player_data_updated.emit(player_data)

func get_setting(setting_name: String):
	return game_settings.get(setting_name, null)

func set_setting(setting_name: String, value):
	game_settings[setting_name] = value
