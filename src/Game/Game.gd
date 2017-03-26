extends Node


func _ready():
	set_process_input(true)

func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _input(event):
	if event.type == InputEvent.KEY && event.scancode == KEY_ESCAPE && event.pressed:
		lobby.call_deferred("change_to_main_menu")
