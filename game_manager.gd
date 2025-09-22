extends Node2D

@onready var pause_menu := $Camera/PauseMenu
@export var is_developer_mode: bool = false

var levelManager = load("res://LevelManager.cs")
var levelManagerNode = levelManager.new()

func _ready():
	# Connect to global GameManager pause signal to control local pause menu
	if GameManager:
		GameManager.game_paused.connect(_on_game_paused)


	if levelManager:
		levelManagerNode.InitLevelManager()

	Engine.max_fps = 0

	# Set current level in LevelManager
	if LevelManager:
		LevelManager.current_level = get_scene_file_path()

func _process(delta):
	updateFPS()

func _on_game_paused(is_paused: bool):
	# Control pause menu visibility through global GameManager
	if pause_menu:
		pause_menu.visible = is_paused

func updateFPS():
	#print(Engine.get_frames_per_second())
	pass
