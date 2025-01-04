extends CharacterBody2D

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

#var velocity = Vector2()
var runDeceleate: bool = false
var isJumping: bool
var initJump: bool = false
var isDropping: bool = false
var coyoteTimer: Timer
var prevFrameOnFloor: bool = false

var current_state = PlayerState.IDLE

@onready var _animated_sprite = $AnimatedSprite2D
@onready var ground_ray := $GroundRay
	


func _physics_process(delta):
	var input_dir = Input.get_action_strength("right") - Input.get_action_strength("left")

	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY / 4
		isJumping = true
		prevFrameOnFloor = true
#	print("v.y", velocity.y)
	print("on floor ? ", is_on_floor())

	if (is_on_floor() or _is_close_to_ground()):
		#if isJumping:
#		print("is on floor")
		isJumping = false
	else:
		velocity.y += GRAVITY * delta
		#print

	if input_dir != 0:
		velocity.x = move_toward(velocity.x, input_dir * max_speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	move_and_slide()
	print("motion mode:, ", motion_mode)
	
	print("is jump?: ", isJumping)
	update_animation_state()


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
	#else:
		## Check if we're moving up or down
		#if velocity.y < 0:
			#new_state = PlayerState.JUMP_UP
		#else:
			#new_state = PlayerState.JUMP_DOWN
	if isJumping:
		if velocity.y < 0:
		#	print("PlayerState.JUMP_UP")
			new_state = PlayerState.JUMP_UP
		if velocity.y > 0:
		#	print("PlayerState.JUMP_DOWN")
			new_state = PlayerState.JUMP_DOWN
	
	#print ("newState: ", new_state)
	#print ("current_state: ", current_state)
	# Only change animation if state changed
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
	# Combine both checks for more reliable ground detection
	return is_on_floor() or _is_close_to_ground()

func _is_close_to_ground() -> bool:
	if ground_ray.is_colliding():
		print("ground Ray. collission: ", ground_ray.get_collider())
		print("ground ray. distance, ", ground_ray.target_position)
		var distance_to_ground = ground_ray.get_collision_point().y - ground_ray.global_position.y
		#print ("GR.GP.y: ", ground_ray.global_position.y)
		return abs(distance_to_ground) < 14.0
	return false


func _ready():
	set_slide_on_ceiling_enabled(false)
	set_floor_stop_on_slope_enabled(false)
	floor_snap_length = 10
	_animated_sprite.play("idle")
	coyoteTimer = Timer.new()
	coyoteTimer.wait_time = COYOTE_TIME
	add_child(coyoteTimer)
	

func _process(delta):
	pass
