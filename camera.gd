extends Camera2D

# Camera follow properties
@export var target_path: NodePath  # Path to the player node
@export var follow_speed: float = 5.0
@export var look_ahead_factor: float = 0.2

# Dead zone properties
@export var use_dead_zone: bool = true
@export var dead_zone_width: float = 200  # Width of dead zone in pixels
@export var dead_zone_height: float = 100  # Height of dead zone in pixels

# Screen shake properties
var shake_amount: float = 0
var shake_duration: float = 0
var default_offset: Vector2 = offset

# Target node reference
var target: Node2D
var dead_zone_rect: Rect2

func _ready() -> void:
	# Get the target node (usually the player)
	if target_path:
		target = get_node(target_path)
		global_position = target.global_position
	
	# Initialize dead zone rectangle
	update_dead_zone()

func update_dead_zone() -> void:
	var screen_size = get_viewport_rect().size
	var center = screen_size / 2
	#dead_zone_rect = Rect2(
		#-screen_size.x - dead_zone_width/2,
		#center.y - dead_zone_height/2,
		#dead_zone_width,
		#dead_zone_height
	#)
	# INIT POSITION and SIZE of DEAD ZONE
	dead_zone_rect.position = get_parent().global_position
	dead_zone_rect.position.x -= dead_zone_width  / 2
	dead_zone_rect.position.y -= dead_zone_height / 2
	
	dead_zone_rect.size = Vector2(dead_zone_width,dead_zone_height)
	
	#print(dead_zone_rect)

func _physics_process(delta: float) -> void:
	if not target:
		return
	
	var target_pos = target.global_position
	var camera_pos = global_position
	
	
	var screenSize = get_viewport_rect().size
	var topLeftPos = global_position - screenSize
	
	
	var screen_size = get_viewport_rect().size
	var center = screen_size / 2
	
	if use_dead_zone:
		#dead_zone_rect.position = get_parent().global_position
		var target_viewport_pos = get_viewport_transform() * (target_pos)
		#print(get_viewport().get_visible_rect().position)
		#var screen_position = get_transform().xform_inv(global_position)
		print(target_viewport_pos)
		# CHECK 1
		#
		#
		#
		#if target_viewport_pos.x > center.x - dead_zone_width / 2:
			#print("target.x > deadzone.x1")
		
		
		if is_target_in_zone(target_viewport_pos):
			print("target in deadzone")
		else:
			print("target not deadzone")
		pass




	
	#if use_dead_zone:
		## Convert target's global position to local viewport coordinates
		#var target_viewport_pos = get_viewport_transform() * (target_pos - global_position)
		#
		## Check if target is outside dead zone and calculate new camera position
		#if not dead_zone_rect.has_point(target_viewport_pos):
			## Horizontal movement
			#if target_viewport_pos.x < dead_zone_rect.position.x:
				#camera_target.x = target_pos.x + dead_zone_rect.position.x
			#elif target_viewport_pos.x > dead_zone_rect.end.x:
				#camera_target.x = target_pos.x - (get_viewport_rect().size.x - dead_zone_rect.end.x)
			#
			## Vertical movement
			#if target_viewport_pos.y < dead_zone_rect.position.y:
				#camera_target.y = target_pos.y + dead_zone_rect.position.y
			#elif target_viewport_pos.y > dead_zone_rect.end.y:
				#camera_target.y = target_pos.y - (get_viewport_rect().size.y - dead_zone_rect.end.y)
	#else:
		## Regular follow behavior
		#camera_target = target_pos
		#
		## Add look-ahead based on player velocity if available
		#if target.has_method("get_velocity"):
			#var target_velocity = target.get_velocity()
			#camera_target += target_velocity * look_ahead_factor
	#
	## Smoothly move camera to target position
	#global_position = global_position.lerp(camera_target, follow_speed * delta)
	#
	## Apply screen shake if active
	#if shake_duration > 0:
		#shake_duration -= delta
		#offset = default_offset + Vector2(
			#randf_range(-1.0, 1.0) * shake_amount,
			#randf_range(-1.0, 1.0) * shake_amount
		#)
		#
		#if shake_duration <= 0:
			#shake_duration = 0
			#offset = default_offset


func is_target_in_zone(targetPos: Vector2) -> bool:
	var screen_size = get_viewport_rect().size
	var center = screen_size / 2
	print("center.x1_", center.x - dead_zone_width / 2)
	print("center.x2_", center.x + dead_zone_width / 2)
		
	print("center.y_1", center.y - dead_zone_height / 2)
	print("center.y_2", center.y + dead_zone_height / 2)
	
	if targetPos.x < center.x - dead_zone_width / 2:
		return false
	if targetPos.x > center.x + dead_zone_width / 2:
		return false
	if targetPos.y < center.y - dead_zone_height / 2:
		return false
	if targetPos.y > center.y + dead_zone_height / 2:
		return false

	return true
#		
# Function to trigger screen shake
func shake(amount: float, duration: float) -> void:
	shake_amount = amount
	shake_duration = duration

# Optional: Debug draw to visualize dead zone (can be removed in production)
func _draw() -> void:
	if use_dead_zone:
		var color = Color(1, 0, 0, 0.2)
		draw_rect(dead_zone_rect, color, true)
