class_name UIManager
extends Node2D

enum UI_MODE
{
	IN_GAME
}

var uiState: UI_MODE
var uiElements := []

func _ready():
	#uiElements.append($IN_GAME)
	pass # Replace with function body.

func _process(delta):
	#match uiState:
		#uiState.IN_GAME: 
			#for ui in uiElements.get_items():
				#ui.visible = false
	pass
