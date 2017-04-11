extends Node

# Ground has collision layer's bit 1 set, 
# because KinematicBody::move() doesn't use collision layer/mask correctly
# bit 1 is for Player 

func _ready():
	set_process_input(true)

func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event):
	if event.type == InputEvent.KEY && event.scancode == KEY_ESCAPE && event.pressed:
		lobby.call_deferred("change_to_main_menu")
