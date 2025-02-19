class_name InteractiveArea2D
extends Area2D

signal interacted
signal interaction_available
signal interaction_unavailable

@export var interact_input_action = "interact"


func _ready():
	set_process_unhandled_input(false)


func _unhandled_input(event):
	if event.is_action_pressed(interact_input_action):
		interacted.emit()
		get_viewport().set_input_as_handled()


func _on_area_entered(area):
	set_process_unhandled_input(true)
	print(area.name)
	
	var p = area.get_parent()
	print(p.name)
	interaction_available.emit()


func _on_area_exited(area):
	set_process_unhandled_input(false)
	print(area.name)
	var p = area.get_parent()
	print(p.name)
	interaction_unavailable.emit()
