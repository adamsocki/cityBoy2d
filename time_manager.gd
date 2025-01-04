class_name TimeManager
extends Node2D


enum TimeOfDay
{
	MORNING,
	MIDMORNING,
	NOON,
	AFTERNOON,
	EVENING,
	NIGHT,
}

var game_time: float


# Called when the node enters the scene tree for the first time.
func _ready():
	
	game_time = 0
	pass # Replace with function body.

func update_time_manager(delta):
	game_time += delta
	print(game_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
