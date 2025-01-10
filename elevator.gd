@tool

extends Area2D
var end_position_node: Node2D

@export var vertical_position_01: float:
	set(value):
		vertical_position_01 = value
		# Update position when the value changes in editor
		if Engine.is_editor_hint() and end_position_node:
			end_position_node.position.y = value

func _ready():
	# Get the node reference
	end_position_node = $PositionPoint01
	
	if Engine.is_editor_hint():
		# Update position in editor
		if end_position_node:
			end_position_node.position.y = vertical_position_01



func _on_body_entered(body):
	if Engine.is_editor_hint():
		pass
	else:
		if body.get_name() == "Player":
			print("player")
