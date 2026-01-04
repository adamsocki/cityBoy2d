extends ScrollContainer

# Level Debug Tab - Controls for level/spatial visualization debugging

# Node references
var transitions_toggle: CheckButton
var spawn_points_toggle: CheckButton
var interactive_areas_toggle: CheckButton
var camera_dead_zones_toggle: CheckButton

var level_name_label: Label
var spawn_point_label: Label
var transition_count_label: Label
@onready var debug_draw_manager = get_node_or_null("/root/DebugDrawManager")

func _ready():
	_get_node_references()
	_apply_theme_roles()
	_connect_signals()
	_sync_with_manager()

func _apply_theme_roles() -> void:
	if level_name_label:
		level_name_label.set_meta("debug_theme_role", "mono_value")
	if spawn_point_label:
		spawn_point_label.set_meta("debug_theme_role", "mono_value")
	if transition_count_label:
		transition_count_label.set_meta("debug_theme_role", "mono_value")

func _get_node_references():
	transitions_toggle = find_child("TransitionsToggle", true, false) as CheckButton
	spawn_points_toggle = find_child("SpawnPointsToggle", true, false) as CheckButton
	interactive_areas_toggle = find_child("InteractiveAreasToggle", true, false) as CheckButton
	camera_dead_zones_toggle = find_child("CameraDeadZonesToggle", true, false) as CheckButton

	level_name_label = find_child("LevelNameLabel", true, false) as Label
	spawn_point_label = find_child("SpawnPointLabel", true, false) as Label
	transition_count_label = find_child("TransitionCountLabel", true, false) as Label

func _connect_signals():
	transitions_toggle.toggled.connect(_on_transitions_toggled)
	spawn_points_toggle.toggled.connect(_on_spawn_points_toggled)
	interactive_areas_toggle.toggled.connect(_on_interactive_areas_toggled)
	camera_dead_zones_toggle.toggled.connect(_on_camera_dead_zones_toggled)


func _sync_with_manager():
	# Initialize toggles from DebugDrawManager state
	if debug_draw_manager:
		transitions_toggle.button_pressed = debug_draw_manager.draw_level_transitions
		spawn_points_toggle.button_pressed = debug_draw_manager.draw_spawn_points
		interactive_areas_toggle.button_pressed = debug_draw_manager.draw_interactive_areas
		camera_dead_zones_toggle.button_pressed = debug_draw_manager.draw_camera_dead_zones

func _process(_delta):
	_update_info_panel()

func _update_info_panel():
	# Update level name
	if LevelManager and LevelManager.current_level:
		var level_path = LevelManager.current_level
		var level_name = level_path.get_file().get_basename()
		level_name_label.text = "Level: " + level_name
	else:
		level_name_label.text = "Level: Unknown"

	# Update spawn point info
	if GameManager:
		var player_data = GameManager.get_player_data()
		if player_data.has("spawn_point"):
			spawn_point_label.text = "Active Spawn: " + str(player_data.spawn_point)
		else:
			spawn_point_label.text = "Active Spawn: default"
	else:
		spawn_point_label.text = "Active Spawn: N/A"

	# Count level transitions in current scene
	var transitions = get_tree().get_nodes_in_group("level_transitions")
	transition_count_label.text = "Transitions: " + str(transitions.size())

func _on_transitions_toggled(enabled: bool):
	if debug_draw_manager:
		debug_draw_manager.set_debug_feature("draw_level_transitions", enabled)

func _on_spawn_points_toggled(enabled: bool):
	if debug_draw_manager:
		debug_draw_manager.set_debug_feature("draw_spawn_points", enabled)

func _on_interactive_areas_toggled(enabled: bool):
	if debug_draw_manager:
		debug_draw_manager.set_debug_feature("draw_interactive_areas", enabled)

func _on_camera_dead_zones_toggled(enabled: bool):
	if debug_draw_manager:
		debug_draw_manager.set_debug_feature("draw_camera_dead_zones", enabled)
