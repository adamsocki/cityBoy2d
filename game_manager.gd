extends Node2D

@onready var pause_menu := $Camera/PauseMenu
@export var timeManager: TimeManager

func _ready():
	if timeManager:
		timeManager.init_time_manager()
	Engine.max_fps = 0


func _process(delta):
	if timeManager:
		timeManager.update_time_manager(delta)


	if Input.is_action_just_pressed("pause"):
		pause_menu.visible = !pause_menu.visible
		
	updateFPS()



	
func updateFPS():
	print(Engine.get_frames_per_second())
