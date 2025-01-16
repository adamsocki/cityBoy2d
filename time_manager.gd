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
var time_of_day: TimeOfDay = TimeOfDay.EVENING


func init_time_manager():
	game_time = 0


func update_time_manager(delta):
	game_time += delta
	#print(game_time)
