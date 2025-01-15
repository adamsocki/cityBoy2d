
extends Node2D


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0

@export var initial_direction = -1

@export var npc_speed: float

@onready var body = $BumpingEnemy2D

@onready var _animated_sprite = $BumpingEnemy2D/AnimatedSprite2D


enum STATES{WALK, IDLE}

var state = STATES.WALK

func _ready():
	body.speed = npc_speed
	body.direction = initial_direction
	_animated_sprite.play("idle")
	
	if body.direction > 0:
		_animated_sprite.flip_h = false
	elif body.direction < 0:
		_animated_sprite.flip_h = true

func _physics_process(delta):
	match state:
		STATES.IDLE:
			_animated_sprite.play("idle")
		STATES.WALK:
			_animated_sprite.play("walk")
			
	if body.direction > 0:
		_animated_sprite.flip_h = false
	elif body.direction < 0:
		_animated_sprite.flip_h = true
