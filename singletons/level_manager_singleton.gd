extends Node

signal level_transition_started(from_level: String, to_level: String)
signal level_transition_completed(level_name: String)
signal level_loaded(level_name: String)

var current_level: String = ""
var level_completion_data = {}
var available_levels = ["Level1", "Level2"]
var is_transitioning: bool = false

func _ready():
	add_to_group("level_manager")

func transition_to_level(level_path: String, spawn_point: String = "default"):
	if is_transitioning:
		print("Level transition already in progress")
		return

	is_transitioning = true
	level_transition_started.emit(current_level, level_path)

	# Store player data before transition
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_global_position"):
		GameManager.save_player_data({
			"checkpoint_position": player.global_position,
			"current_level": current_level,
			"spawn_point": spawn_point
		})

	# Create fade transition
	await create_fade_transition()

	# Change scene
	var previous_level = current_level
	current_level = level_path
	get_tree().change_scene_to_file(level_path)

	# Wait for scene to load
	await get_tree().process_frame
	await get_tree().process_frame

	# Handle spawn point after level loads
	_handle_spawn_point(spawn_point)

	is_transitioning = false
	level_transition_completed.emit(level_path)
	level_loaded.emit(level_path)

func create_fade_transition():
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.modulate.a = 0.0
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 1000

	get_tree().root.add_child(overlay)

	# Fade out
	var tween_out = get_tree().create_tween()
	tween_out.tween_property(overlay, "modulate:a", 1.0, 0.5)
	await tween_out.finished

	# Wait a bit
	await get_tree().create_timer(0.2).timeout

	# Fade in after scene change (will be called after scene loads)
	get_tree().process_frame.connect(_fade_in_overlay.bind(overlay), CONNECT_ONE_SHOT)

func _fade_in_overlay(overlay: ColorRect):
	if overlay and is_instance_valid(overlay):
		var tween_in = get_tree().create_tween()
		tween_in.tween_property(overlay, "modulate:a", 0.0, 0.5)
		await tween_in.finished
		overlay.queue_free()

func _handle_spawn_point(spawn_point_id: String):
	# Find spawn point in the current scene
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	var target_spawn: Node2D = null

	for spawn in spawn_points:
		if spawn.has_method("get_spawn_id") and spawn.get_spawn_id() == spawn_point_id:
			target_spawn = spawn
			break

	# If no specific spawn point found, use default
	if not target_spawn and spawn_points.size() > 0:
		target_spawn = spawn_points[0]

	# Position player at spawn point
	if target_spawn:
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("set_global_position"):
			player.global_position = target_spawn.global_position

func mark_level_completed(level_name: String, completion_data: Dictionary = {}):
	level_completion_data[level_name] = {
		"completed": true,
		"completion_time": Time.get_unix_time_from_system(),
		"data": completion_data
	}

func is_level_completed(level_name: String) -> bool:
	return level_completion_data.has(level_name) and level_completion_data[level_name].get("completed", false)

func get_level_completion_data(level_name: String) -> Dictionary:
	return level_completion_data.get(level_name, {})

func get_available_levels() -> Array:
	return available_levels

func add_available_level(level_name: String):
	if not available_levels.has(level_name):
		available_levels.append(level_name)

func get_current_level() -> String:
	return current_level

func reload_current_level():
	if not current_level.is_empty():
		transition_to_level(current_level, "default")
