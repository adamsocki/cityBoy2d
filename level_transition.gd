extends Area2D

@export var next_level_scene: String = ""
@export var spawn_point: String = "default"
@export var transition_delay: float = 0.2

var player: CharacterBody2D
var is_transitioning: bool = false

func _ready():
	body_entered.connect(_on_player_entered)
	add_to_group("level_transitions")

func _on_player_entered(body):
	if body.name == "Player" and not is_transitioning:
		player = body
		is_transitioning = true
		transition_to_level()

func transition_to_level():
	if next_level_scene.is_empty():
		print("No next level scene specified")
		is_transitioning = false
		return

	# Small delay to prevent accidental re-triggering
	await get_tree().create_timer(transition_delay).timeout

	# Use LevelManager for transition instead of direct scene change
	LevelManager.transition_to_level(next_level_scene, spawn_point)
