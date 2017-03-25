extends Node


func _ready():
	set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event.type == InputEvent.KEY && event.pressed && event.scancode == KEY_ESCAPE:
		lobby.call_deferred("go_to_main_menu")