extends CharacterBody2D

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


func _physics_process(delta):
	var input_dir = Input.get_action_strength("right") - Input.get_action_strength("left")
	#print("dec", friction)

	if input_dir != 0 and !isDropping:
		velocity.x += input_dir * acceleration * delta
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
	else:
		if (abs(velocity.x) > 0):
			var deceleration = friction * delta
			velocity.x -= sign(velocity.x) * min(abs(velocity.x), deceleration)

	if not is_on_floor():
		velocity.y += gravity * delta
		if isJumping and Input.is_action_just_pressed("jump"):
			drop()
			#print("drop")

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		jump()

	if initJump:
		pass


	move_and_slide()
	#print("vel", velocity)

	if is_on_floor():
		#print("The character is on the floor!")
		if isJumping:
			isJumping = false
		if isDropping:
			isDropping = false
	else:
		pass
		#print("The character is not on the floor!")
		
	if $RayCast2D.collision_mask == 1:
		print("ray hit 1")
	var rayCollission = $RayCast2D.get_collider()
	
	if (rayCollission):
		print("ray collide: ", rayCollission.name)
	if $RayCast2D.is_colliding():
		var character_pos = global_position
		var ray_pos = $RayCast2D.global_position
		var collision_pos = $RayCast2D.get_collision_point()
	
		print("Character position Y: ", character_pos.y)
		print("Ray position Y: ", ray_pos.y)
		print("Collision point Y: ", collision_pos.y)
		print("Distance to ground: ", collision_pos.y - ray_pos.y)

		
	
	




func drop():
	velocity.y = drop_accel
	velocity.x = 0
	isDropping = true
	isJumping = false

func jump():
	velocity.y = -jump_accel
	isJumping = true











# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
