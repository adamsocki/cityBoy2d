extends CharacterBody2D

enum PlayerState {
	IDLE,
	WALK, 
	JUMP_UP,
	JUMP_DOWN, 
	ATTACK,
}

@export var gravity: float

@export var acceleration: float
@export var max_speed: float
@export var friction: float
@export var jump_accel: float
@export var drop_accel: float

#var velocity = Vector2()
var runDeceleate: bool = false
var isJumping: bool = false
var initJump: bool = false
var isDropping: bool = false

var current_state = PlayerState.IDLE

@onready var _animated_sprite = $AnimatedSprite2D
@onready var ground_ray := $GroundRay
	


func _physics_process(delta):
	var input_dir = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if input_dir != 0:
		velocity.x += input_dir * acceleration * delta
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
	else:
		var friction = 1000.0
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	if not is_grounded():
		velocity.y += gravity * delta
		if isJumping and Input.is_action_just_pressed("jump"):
			drop()
	elif Input.is_action_just_pressed("jump"):
		jump()
	
	floor_snap_length = 32
	floor_max_angle = deg_to_rad(45) 
	floor_stop_on_slope = true
	
	move_and_slide()
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
	
	if is_grounded():
		if abs(velocity.x) > 0:
			new_state = PlayerState.WALK
		else:
			new_state = PlayerState.IDLE
	else:
		# Check if we're moving up or down
		if velocity.y < 0:
			new_state = PlayerState.JUMP_UP
		else:
			new_state = PlayerState.JUMP_DOWN
	
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
		var distance_to_ground = ground_ray.get_collision_point().y - global_position.y
		return distance_to_ground < 1.0
	return false


# Called when the node enters the scene tree for the first time.
func _ready():
	_animated_sprite.play("idle")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
