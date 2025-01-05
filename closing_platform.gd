


extends Node2D


@onready var door_top: Area2D = $DoorTop
@onready var door_bottom: Area2D = $DoorBottom

var is_open = false
var animation_speed = 300  # pixels per second
var door_travel = 100     # how far each door moves
var initial_top_pos: Vector2
var initial_bottom_pos: Vector2

func _ready():
	initial_top_pos = door_top.position
	initial_bottom_pos = door_bottom.position

func toggle_door():
	if is_open:
		close_door()
	else:
		open_door()


func open_door():
	pass
	
func close_door():
	pass
