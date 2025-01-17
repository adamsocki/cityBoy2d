
extends Node2D


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

@export var initial_direction = -1

@export var npc_speed: float

@onready var body = $BumpingEnemy2D

@onready var _animated_sprite = $BumpingEnemy2D/AnimatedSprite2D
@onready var interactive_area_forward_collision = $BumpingEnemy2D/interactive_area_forward/interactive_area_forward_collision


enum STATES{WALK, IDLE}

var state = STATES.WALK
var previous_direction = 0

func _ready():
	body.speed = npc_speed
	body.direction = initial_direction
	_animated_sprite.play("idle")
	
	if body.direction > 0:
		_animated_sprite.flip_h = false
	elif body.direction < 0:
		#interactive_area_forward_collision.position.x = -interactive_area_forward_collision.position.x
		_animated_sprite.flip_h = true

func _physics_process(delta):
	match state:
		STATES.IDLE:
			_animated_sprite.play("idle")
		STATES.WALK:
			_animated_sprite.play("walk")
			
	if body.direction > 0:
		if previous_direction < 0: 
			_animated_sprite.flip_h = false
			interactive_area_forward_collision.position.x = -interactive_area_forward_collision.position.x
		previous_direction = body.direction
	elif body.direction < 0:
		if previous_direction > 0: 
			_animated_sprite.flip_h = true
			interactive_area_forward_collision.position.x = -interactive_area_forward_collision.position.x
		previous_direction = body.direction
		
		





func _on_interactive_area_2d_interacted():
	print("_on_interactive_area_2d_interacted")


func _on_interactive_area_2d_interaction_available():
	print("_on_interactive_area_2d_interaction_available")



func _on_interactive_area_2d_interaction_unavailable():
	print("_on_interactive_area_2d_interaction_unavailable")
