extends Node2D

@onready var door_top: Area2D = $DoorTop
@onready var door_bottom: Area2D = $DoorBottom

var is_open = false
@export var animation_speed: float
@export var door_travel: float
var initial_top_pos: Vector2
var initial_bottom_pos: Vector2
var target_top_pos: Vector2
var target_bottom_pos: Vector2

func _ready():
	# Store initial positions
	initial_top_pos = door_top.position
	initial_bottom_pos = door_bottom.position
	target_top_pos = initial_top_pos
	target_bottom_pos = initial_bottom_pos

# Call this to toggle the door state
func toggle_door():
	if is_open:
		close_door()
	else:
		open_door()

func open_door():
	is_open = true
	# Set target positions for opening
	target_top_pos = initial_top_pos + Vector2(0, -door_travel)
	target_bottom_pos = initial_bottom_pos + Vector2(0, door_travel)

func close_door():
	is_open = false
	# Set target positions for closing
	target_top_pos = initial_top_pos
	target_bottom_pos = initial_bottom_pos

func _process(delta):
	if Input.is_action_just_pressed("space"):
		toggle_door()

	# Smoothly move door parts toward their target positions
	door_top.position = door_top.position.lerp(target_top_pos, animation_speed * delta / door_travel)
	door_bottom.position = door_bottom.position.lerp(target_bottom_pos, animation_speed * delta / door_travel)
