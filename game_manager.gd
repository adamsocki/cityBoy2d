extends Node2D

#@export var pause_menu: Control
@onready var pause_menu := $Camera/PauseMenu
@export var timeManager: TimeManager

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timeManager:
		timeManager.update_time_manager(delta)
	if Input.is_action_just_pressed("pause"):
		pause_menu.visible = !pause_menu.visible
