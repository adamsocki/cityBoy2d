extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(get_viewport().get_mouse_position())
	pass



func _draw():
	var rec_draw: Rect2
	rec_draw = Rect2(10, 100, 50, 150)
	var color = Color(1, 0, 0, 0.2)
	draw_rect(rec_draw, color, true)
