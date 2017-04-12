extends Particles



func _ready():
	set_process(true)


func _process(delta):
	if !is_emitting():
		queue_free()
