class_name SpawnPoint
extends Marker2D

@export var spawn_id: String = "default"
@export var spawn_direction: int = 1  # 1 for right, -1 for left
@export var is_checkpoint: bool = false

func _ready():
	add_to_group("spawn_points")
	

	# Visual indicator in editor (will not appear in game)
	if Engine.is_editor_hint():
		_create_editor_visual()

func get_spawn_id() -> String:
	return spawn_id

func get_spawn_position() -> Vector2:
	return global_position

func get_spawn_direction() -> int:
	return spawn_direction

func is_spawn_checkpoint() -> bool:
	return is_checkpoint

func activate_spawn():
	"""Called when player reaches this spawn point"""
	if is_checkpoint:
		# Save this as a checkpoint
		GameManager.save_player_data({
			"checkpoint_position": global_position,
			"checkpoint_spawn_id": spawn_id,
			"checkpoint_level": LevelManager.get_current_level()
		})
		print("Checkpoint activated: ", spawn_id)

func _create_editor_visual():
	"""Creates a visual indicator for the spawn point in the editor"""
	if not Engine.is_editor_hint():
		return

	# Create a simple icon/shape to show spawn point location
	var icon = ColorRect.new()
	icon.size = Vector2(32, 32)
	icon.position = Vector2(-16, -16)  # Center the icon
	icon.color = Color.GREEN if spawn_id == "default" else Color.YELLOW
	icon.color.a = 0.7
	add_child(icon)

	# Add a label with the spawn ID
	var label = Label.new()
	label.text = spawn_id
	label.position = Vector2(-16, 20)
	label.size = Vector2(64, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
