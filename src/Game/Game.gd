extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process_input(true)


func _input(event):
	if event.type == InputEvent.KEY && event.scancode == KEY_ESCAPE && event.pressed:
		lobby.call_deferred("change_to_main_menu")
