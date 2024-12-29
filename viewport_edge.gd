extends Area2D

enum ViewportSide {
	LEFT,
	RIGHT,
	TOP,
	BOTTOM,
}


@export var viewportSide: ViewportSide
@export var camera: Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if 
	pass
	
	
func _on_body_entered(body):
	set_process(true)
	print(body)


func _on_body_exited(body):
	pass
