extends Node2D

@onready var pause_menu := $PauseMenu
@onready var player := $Player
@onready var sky_color_manager := $SkyColorManager

func _ready():
	# Connect to global GameManager pause signal
	if GameManager:
		GameManager.game_paused.connect(_on_game_paused)

	# Set current level in LevelManager
	if LevelManager:
		LevelManager.current_level = get_scene_file_path()

	# Connect to TimeManager for sky color updates
	if TimeManager and sky_color_manager:
		TimeManager.time_of_day_changed.connect(sky_color_manager._on_time_manager_time_of_day_changed)

	# Position player at spawn point if coming from level transition
	_handle_spawn_positioning()

func _handle_spawn_positioning():
	# Check if player data has a specific spawn point
	if GameManager and player:
		var player_data = GameManager.get_player_data()
		if player_data.has("spawn_point") and player_data.spawn_point != "default":
			_position_player_at_spawn(player_data.spawn_point)
		elif player_data.has("checkpoint_position"):
			player.global_position = player_data.checkpoint_position

func _position_player_at_spawn(spawn_id: String):
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	for spawn in spawn_points:
		if spawn.has_method("get_spawn_id") and spawn.get_spawn_id() == spawn_id:
			player.global_position = spawn.global_position
			if spawn.has_method("get_spawn_direction"):
				# Set player direction if the spawn point specifies one
				var direction = spawn.get_spawn_direction()
				if player.has_method("set_facing_direction"):
					player.set_facing_direction(direction)
			break

func _exit_tree():
	# Disconnect signals when level is being freed
	if TimeManager and sky_color_manager:
		if TimeManager.time_of_day_changed.is_connected(sky_color_manager._on_time_manager_time_of_day_changed):
			TimeManager.time_of_day_changed.disconnect(sky_color_manager._on_time_manager_time_of_day_changed)

func _on_game_paused(is_paused: bool):
	# Control pause menu visibility through global GameManager
	if pause_menu:
		pause_menu.visible = is_paused
