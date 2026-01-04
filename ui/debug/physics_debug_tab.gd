extends ScrollContainer

# Physics Debug Tab - Controls for physics visualization debugging

# Node references
var native_collision_toggle: CheckButton
var collision_toggle: CheckButton
var raycast_toggle: CheckButton
var velocity_toggle: CheckButton
var state_toggle: CheckButton

var player_state_label: Label
var velocity_label: Label
var ground_status_label: Label
@onready var debug_draw_manager = get_node_or_null("/root/DebugDrawManager")

func _ready():
	_get_node_references()
	_apply_theme_roles()
	_connect_signals()
	_sync_with_manager()

func _apply_theme_roles() -> void:
	if player_state_label:
		player_state_label.set_meta("debug_theme_role", "mono_value")
	if velocity_label:
		velocity_label.set_meta("debug_theme_role", "mono_value")
	if ground_status_label:
		ground_status_label.set_meta("debug_theme_role", "mono_value")

func _get_node_references():
	native_collision_toggle = find_child("NativeCollisionToggle", true, false) as CheckButton
	collision_toggle = find_child("CollisionToggle", true, false) as CheckButton
	raycast_toggle = find_child("RaycastToggle", true, false) as CheckButton
	velocity_toggle = find_child("VelocityToggle", true, false) as CheckButton
	state_toggle = find_child("StateToggle", true, false) as CheckButton

	player_state_label = find_child("PlayerStateLabel", true, false) as Label
	velocity_label = find_child("VelocityLabel", true, false) as Label
	ground_status_label = find_child("GroundStatusLabel", true, false) as Label

func _connect_signals():
	native_collision_toggle.toggled.connect(_on_native_collision_toggled)
	collision_toggle.toggled.connect(_on_collision_toggled)
	raycast_toggle.toggled.connect(_on_raycast_toggled)
	velocity_toggle.toggled.connect(_on_velocity_toggled)
	state_toggle.toggled.connect(_on_state_toggled)


func _sync_with_manager():
	# Initialize toggles from DebugDrawManager state
	if debug_draw_manager:
		native_collision_toggle.button_pressed = debug_draw_manager.native_collision_shapes
		collision_toggle.button_pressed = debug_draw_manager.draw_collision_shapes
		raycast_toggle.button_pressed = debug_draw_manager.draw_raycasts
		velocity_toggle.button_pressed = debug_draw_manager.draw_velocity_vectors
		state_toggle.button_pressed = debug_draw_manager.draw_state_info

func _process(_delta):
	_update_info_panel()

func _update_info_panel():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Update player state
		if player.has_method("get_state_name"):
			player_state_label.text = "State: " + player.get_state_name()
		elif player.get("current_state") != null:
			var state_names = ["IDLE", "WALK", "JUMP_UP", "JUMP_DOWN", "ATTACK"]
			var state_idx = player.current_state
			if state_idx >= 0 and state_idx < state_names.size():
				player_state_label.text = "State: " + state_names[state_idx]
			else:
				player_state_label.text = "State: UNKNOWN"
		else:
			player_state_label.text = "State: N/A"

		# Update velocity
		var vel = player.get("velocity")
		if vel is Vector2:
			velocity_label.text = "Velocity: (%.1f, %.1f)" % [vel.x, vel.y]
		else:
			velocity_label.text = "Velocity: N/A"

		# Update ground status
		if player.has_method("is_grounded"):
			var grounded = player.is_grounded()
			ground_status_label.text = "Grounded: " + ("YES" if grounded else "NO")
		elif player.has_method("is_on_floor"):
			var on_floor = player.is_on_floor()
			ground_status_label.text = "Grounded: " + ("YES" if on_floor else "NO")
		else:
			ground_status_label.text = "Grounded: N/A"
	else:
		player_state_label.text = "State: No Player"
		velocity_label.text = "Velocity: N/A"
		ground_status_label.text = "Grounded: N/A"

func _on_native_collision_toggled(enabled: bool):
	if debug_draw_manager:
		debug_draw_manager.set_debug_feature("native_collision_shapes", enabled)

func _on_collision_toggled(enabled: bool):
	if debug_draw_manager:
		debug_draw_manager.set_debug_feature("draw_collision_shapes", enabled)

func _on_raycast_toggled(enabled: bool):
	if debug_draw_manager:
		debug_draw_manager.set_debug_feature("draw_raycasts", enabled)

func _on_velocity_toggled(enabled: bool):
	if debug_draw_manager:
		debug_draw_manager.set_debug_feature("draw_velocity_vectors", enabled)

func _on_state_toggled(enabled: bool):
	if debug_draw_manager:
		debug_draw_manager.set_debug_feature("draw_state_info", enabled)
