extends Camera2D

# Camera follow properties
@export var target_path: NodePath 
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
	if target_path:
		target = get_node(target_path)
		global_position = target.global_position
	
	update_dead_zone()

func update_dead_zone() -> void:
	var screen_size = get_viewport_rect().size
	var center = screen_size / 2
	
	dead_zone_rect.position = get_parent().global_position
	dead_zone_rect.position.x -= dead_zone_width  / 2
	dead_zone_rect.position.y -= dead_zone_height / 2
	
	dead_zone_rect.size = Vector2(dead_zone_width,dead_zone_height)

func _process(delta):
	#print("camera Position", get_transform())
	#print("target transform", target.get_transform())
	#print("target get global transform with cangvas", target.get_global_transform_with_canvas())
	#print("get_viewport_rect().size.x", get_viewport_rect().size.x)
	
	if !target:
		return
		
	# Get the target's position relative to the camera's viewport
	var target_pos = target.get_global_position()
	#var camera_pos = global_position
	var camera_pos = global_position
	var new_camera_pos = camera_pos
	
	# Convert target position to camera's local coordinates
	var target_local_pos = target_pos - camera_pos
	
	if abs(target_local_pos.x) > dead_zone_width / 2:
		var offset_x = target_local_pos.x - (sign(target_local_pos.x) * dead_zone_width / 2)
		new_camera_pos.x = camera_pos.x + offset_x
	
	if abs(target_local_pos.y) > dead_zone_height / 2:
		var offset_y = target_local_pos.y - (sign(target_local_pos.y) * dead_zone_height / 2)
		new_camera_pos.y = camera_pos.y + offset_y
	
	if new_camera_pos != camera_pos:
		global_position = global_position.lerp(new_camera_pos, follow_speed * delta)

func _physics_process(delta: float) -> void:
	if not target:
		return

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
