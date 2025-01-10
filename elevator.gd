extends Area2D

var end_position_node: Node2D
var is_moving := false
var initial_y: float

@export var vertical_position_01: float:
	set(value):
		vertical_position_01 = value
		# Update position when the value changes in editor
		if Engine.is_editor_hint() and end_position_node:
			end_position_node.position.y = value

@export var animation_duration: float = 1.0  # Duration in seconds
@export var elevator_platform: NodePath  # Reference to the platform node
@onready var platform: Node2D = $PositionPoint01

func _ready():
	# Get the node references
	end_position_node = platform
	platform = get_node(elevator_platform)
	initial_y = self.position.y
	
	if Engine.is_editor_hint():
		# Update position in editor
		if end_position_node:
			end_position_node.position.y = vertical_position_01

func _on_body_entered(body):
	if Engine.is_editor_hint():
		pass
	else:
		if body.name == "Player" and !is_moving:
			move_elevator()

func move_elevator():
	is_moving = true
	
	# Create a new tween
	var tween = create_tween()
	
	# Animate the platform's position relative to its starting position
	tween.tween_property(
		self,  # Node to animate
		"position:y",  # Property to animate
		initial_y + vertical_position_01,  # Initial Y + distance to move
		animation_duration  # Duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	# Connect to the finished signal
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	is_moving = false
