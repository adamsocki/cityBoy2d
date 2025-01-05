extends Node2D

@onready var pause_menu := $Camera/PauseMenu
@export var timeManager: TimeManager

func _ready():
	if timeManager:
		timeManager.init_time_manager()

func _process(delta):
	if timeManager:
		timeManager.update_time_manager(delta)
		
		
		
		
	if Input.is_action_just_pressed("pause"):
		pause_menu.visible = !pause_menu.visible
