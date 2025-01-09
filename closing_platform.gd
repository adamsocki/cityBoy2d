extends Node2D

@onready var original_platform: Node2D = $Area2D2
@onready var door_top: Node2D = $Area2D2/DoorTop
@onready var door_bottom: Node2D = $Area2D2/DoorBottom

var is_open = false
@export var animation_speed: float = 100
@export var platform_count: int = 7
@export var door_travel: float = 100
var time_since_toggle: float = 0.0
@export var toggle_interval: float = 1.0 

var platforms: Array[Node2D] = []
var platform_doors: Array[Dictionary] = []

func _ready():
	# Store the original platform's data
	var original_door_data = {
		"platform": original_platform,
		"top": door_top,
		"bottom": door_bottom,
		"initial_top_pos": door_top.position,
		"initial_bottom_pos": door_bottom.position,
		"target_top_pos": door_top.position,
		"target_bottom_pos": door_bottom.position
	}
	platform_doors.append(original_door_data)
	platforms.append(original_platform)
	
	# Create duplicates
	for i in range(platform_count - 1):  # -1 because we already have the original
		var new_platform = original_platform.duplicate() as Node2D
		add_child(new_platform)
		new_platform.position = original_platform.position + Vector2(30 * (i + 1), 0)
		platforms.append(new_platform)
		
		# Get door references for the new platform
		var new_top = new_platform.get_node("DoorTop")
		var new_bottom = new_platform.get_node("DoorBottom")
		
		# Store the new platform's door data
		var new_door_data = {
			"platform": new_platform,
			"top": new_top,
			"bottom": new_bottom,
			"initial_top_pos": new_top.position,
			"initial_bottom_pos": new_bottom.position,
			"target_top_pos": new_top.position,
			"target_bottom_pos": new_bottom.position
		}
		platform_doors.append(new_door_data)

func toggle_door():
	if is_open:
		close_door()
	else:
		open_door()

func open_door():
	is_open = true
	for door_data in platform_doors:
		door_data.target_top_pos = door_data.initial_top_pos + Vector2(0, -door_travel)
		door_data.target_bottom_pos = door_data.initial_bottom_pos + Vector2(0, door_travel)

func close_door():
	is_open = false
	for door_data in platform_doors:
		door_data.target_top_pos = door_data.initial_top_pos
		door_data.target_bottom_pos = door_data.initial_bottom_pos

func _process(delta):
	time_since_toggle += delta
	
	if time_since_toggle >= toggle_interval:
		toggle_door()
		time_since_toggle = 0
	
	# Update positions for all platforms
	for door_data in platform_doors:
		var top = door_data["top"]
		var bottom = door_data["bottom"]
		
		# Use a fixed lerp factor
		var lerp_factor = clamp(animation_speed * delta, 0, 1)
		
		# Update positions
		top.position = top.position.lerp(door_data.target_top_pos, lerp_factor)
		bottom.position = bottom.position.lerp(door_data.target_bottom_pos, lerp_factor)
