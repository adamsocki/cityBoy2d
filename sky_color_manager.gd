extends CanvasLayer

@export var parallax_scene: Node2D
@export var sky_transition_duration: float = 0.1

var sky_sprite: Sprite2D
var tween: Tween

@export var sky_colors_per_time_of_day = {
	TimeManager.TimeOfDay.MORNING: Color.WHITE,
	TimeManager.TimeOfDay.MIDMORNING: Color(1.0, 0.95, 0.8),     # Warm white
	TimeManager.TimeOfDay.NOON: Color(0.9, 0.95, 1.0),           # Bright blue-white
	TimeManager.TimeOfDay.AFTERNOON: Color(1.0, 0.9, 0.7),       # Golden
	TimeManager.TimeOfDay.EVENING: Color(1.0, 0.6, 0.4),         # Orange/pink
	TimeManager.TimeOfDay.NIGHT: Color(0.3, 0.3, 0.6),           # Dark blue
}

func _ready():
	if parallax_scene:
		sky_sprite = parallax_scene.get_node("Level1_Parallax/ParallaxLayer/SkyColor")
	else:
		print("Error: parallax_scene is null in sky_color_manager")

	# Connect to the TimeManager singleton
	if TimeManager:
		TimeManager.time_of_day_changed.connect(_on_time_manager_time_of_day_changed)

func init_me():
	# Legacy function kept for compatibility but now calls _ready functionality
	if not sky_sprite and parallax_scene:
		sky_sprite = parallax_scene.get_node("Level1_Parallax/ParallaxLayer/SkyColor")
	
func update_color_sky_change_manager(delta):
	pass



func _on_time_manager_time_of_day_changed(new_time: TimeManager.TimeOfDay) -> void:
	print("_on_time_manager_time_of_day_changed in sky color manager")
	if sky_sprite:
		print("sky_sprite and timeManager in sky color manager")
		
		var time_to_use = new_time
		var target_color = sky_colors_per_time_of_day[time_to_use]
		
		var dev_mode = get_tree().get_first_node_in_group("developer_mode")
		if dev_mode and dev_mode.is_developer_mode and dev_mode.use_manual_colors:
			time_to_use = dev_mode.manual_time_of_day
			target_color = sky_colors_per_time_of_day[time_to_use]
		
		#var target_color = sky_colors_per_time_of_day[time_to_use]
		
		# Create smooth color transition
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(sky_sprite, "modulate", target_color, sky_transition_duration)
	pass # Replace with function body.
