
extends CharacterBody2D

signal distance_traveled(distance_delta: float)

enum PlayerState {
	IDLE,
	WALK,
	JUMP_UP,
	JUMP_DOWN,
	ATTACK,
}

@export var GRAVITY: float
@export var ACCELERATION: float
@export var max_speed: float
@export var FRICTION: float
@export var jump_accel: float
@export var drop_accel: float
@export var JUMP_VELOCITY: float
@export var MAX_FALL_SPEED: float
@export var COYOTE_TIME: float

#@


@export_flags_2d_physics var pass_through_layer = 2

#var velocity = Vector2()
var runDeceleate: bool = false
var isJumping: bool
var initJump: bool = false
var isDropping: bool = false
var coyoteTimer: Timer
var prevFrameOnFloor: bool = false

var current_state = PlayerState.IDLE

# Distance tracking for time progression
var last_position: Vector2 = Vector2.ZERO
var total_distance: float = 0.0
var distance_tracking_enabled: bool = true

@onready var _animated_sprite = $AnimatedSprite2D
@onready var ground_ray := $GroundRay
@onready var debug_draw_manager = get_node_or_null("/root/DebugDrawManager")

var current_direction: float = 0
	


func _physics_process(delta):
	
	var input_dir = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if input_dir != current_direction:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY / 4
		isJumping = true
		prevFrameOnFloor = true

	if (is_on_floor() or _is_close_to_ground()):
		isJumping = false
	else:
		velocity.y += GRAVITY * delta

	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * max_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Track horizontal distance traveled (only when grounded and walking)
	if distance_tracking_enabled and is_grounded() and abs(velocity.x) > 10.0:
		var current_pos = global_position
		var distance_delta = abs(current_pos.x - last_position.x)

		if distance_delta > 0.1:  # Minimum threshold to avoid jitter
			total_distance += distance_delta
			distance_traveled.emit(distance_delta)

		last_position = current_pos
	else:
		last_position = global_position

	move_and_slide()
	#print("motion mode:, ", motion_mode)
	#print("is jump?: ", isJumping)
	update_animation_state()

	current_direction = input_dir

	# Trigger redraw if debug enabled
	if DeveloperMode.is_developer_mode and _should_debug_draw():
		queue_redraw()


func drop():
	velocity.y = drop_accel
	velocity.x = 0
	isDropping = true
	isJumping = false

func jump():
	velocity.y = -jump_accel
	isJumping = true

func update_animation_state():
	if velocity.x != 0:
		_animated_sprite.flip_h = velocity.x < 0
	
	# Determine the new state
	var new_state = current_state
	
	if is_grounded() or _is_close_to_ground():
		if abs(velocity.x) > 0:
			new_state = PlayerState.WALK
		else:
			new_state = PlayerState.IDLE
	if isJumping:
		if velocity.y < 0:
			new_state = PlayerState.JUMP_UP
		if velocity.y > 0:
			new_state = PlayerState.JUMP_DOWN
	
	if new_state != current_state:
		current_state = new_state
		match current_state:
			PlayerState.IDLE:
				_animated_sprite.play("idle")
			PlayerState.WALK:
				_animated_sprite.play("walk")
			PlayerState.JUMP_UP:
				_animated_sprite.play("jump_up")
			PlayerState.JUMP_DOWN:
				_animated_sprite.play("jump_down")

func is_grounded() -> bool:
	return is_on_floor() or _is_close_to_ground()

func _is_close_to_ground() -> bool:
	if ground_ray.is_colliding():
		var distance_to_ground = ground_ray.get_collision_point().y - ground_ray.global_position.y
		return abs(distance_to_ground) < 14.0
	return false

func _ready():
	add_to_group("player")
	set_slide_on_ceiling_enabled(false)
	set_floor_stop_on_slope_enabled(false)
	floor_snap_length = 10
	_animated_sprite.play("idle")
	coyoteTimer = Timer.new()
	coyoteTimer.wait_time = COYOTE_TIME
	add_child(coyoteTimer)

	# Initialize distance tracking
	last_position = global_position

	# Enable debug drawing
	set_notify_transform(true)

func _process(delta):
	pass

func _should_debug_draw() -> bool:
	if not debug_draw_manager:
		return false
	return (debug_draw_manager.draw_raycasts or
			debug_draw_manager.draw_velocity_vectors or
			debug_draw_manager.draw_state_info)

func _draw():
	if not DeveloperMode.is_developer_mode:
		return
	if not debug_draw_manager:
		return

	# Note: Collision shapes are now visualized using Godot's native debug_collisions_hint
	# Enable via DebugDrawManager.set_debug_feature("native_collision_shapes", true)

	# Draw raycasts
	if debug_draw_manager.draw_raycasts:
		_draw_ground_rays()

	# Draw velocity vector
	if debug_draw_manager.draw_velocity_vectors:
		_draw_velocity_vector()

	# Draw state label
	if debug_draw_manager.draw_state_info:
		_draw_state_label()

func _draw_ground_rays():
	if not ground_ray:
		return

	var color_hit = debug_draw_manager.get_debug_color("raycast_hit")
	var color_miss = debug_draw_manager.get_debug_color("raycast_miss")

	# Ground detection raycast
	if ground_ray.is_colliding():
		var start = ground_ray.global_position - global_position
		var end = ground_ray.get_collision_point() - global_position
		draw_line(start, end, color_hit, 2.0)
		draw_circle(end, 3, color_hit)
	else:
		var start = ground_ray.global_position - global_position
		var end = start + Vector2(0, 14)  # Max raycast distance
		draw_line(start, end, color_miss, 1.0)

func _draw_velocity_vector():
	if velocity.length() < 10:  # Only draw if moving
		return

	var color = debug_draw_manager.get_debug_color("velocity_vector")
	var scaled_vel = velocity * 0.5  # Scale for visibility
	draw_line(Vector2.ZERO, scaled_vel, color, 3.0)

	# Arrowhead
	if scaled_vel.length() > 0:
		var angle = velocity.angle()
		var head_size = 8
		var head1 = scaled_vel + Vector2(cos(angle + 2.5), sin(angle + 2.5)) * head_size
		var head2 = scaled_vel + Vector2(cos(angle - 2.5), sin(angle - 2.5)) * head_size
		draw_line(scaled_vel, head1, color, 3.0)
		draw_line(scaled_vel, head2, color, 3.0)

func _draw_state_label():
	var state_names = ["IDLE", "WALK", "JUMP_UP", "JUMP_DOWN", "ATTACK"]
	var label = state_names[current_state] if current_state < state_names.size() else "UNKNOWN"
	var font = ThemeDB.fallback_font
	var font_size = 12

	# Add velocity info
	var full_text = label + "\nVel: (%.0f, %.0f)" % [velocity.x, velocity.y]
	full_text += "\nGround: " + ("YES" if is_grounded() else "NO")

	# Draw each line
	var lines = full_text.split("\n")
	var y_offset = -60
	for line in lines:
		var text_size = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		var bg_rect = Rect2(Vector2(-text_size.x / 2 - 4, y_offset - font_size), text_size + Vector2(8, 4))
		draw_rect(bg_rect, debug_draw_manager.get_debug_color("label_background"), true)
		draw_string(font, Vector2(-text_size.x / 2, y_offset), line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
		y_offset += font_size + 4
