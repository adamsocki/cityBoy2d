extends Node2D

@onready var pause_menu := $Camera/PauseMenu
@export var timeManager: TimeManager
@export var is_developer_mode: bool = false

var developer_mode: Node

func _ready():
	if timeManager:
		timeManager.init_time_manager()
		timeManager.add_to_group("time_manager")
	
	# Create and add developer mode
	developer_mode = preload("res://developer_mode.gd").new()
	add_child(developer_mode)
	developer_mode.add_to_group("developer_mode")
	
	Engine.max_fps = 0


func _process(delta):
	if timeManager:
		timeManager.update_time_manager(delta)

	if Input.is_action_just_pressed("pause"):
		pause_menu.visible = !pause_menu.visible
		
	updateFPS()


func updateFPS():
	#print(Engine.get_frames_per_second())
	pass
