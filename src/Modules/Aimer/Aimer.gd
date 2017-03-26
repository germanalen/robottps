extends KinematicBody

var _player
func set_player(player):
	_player = player


sync var _target = Vector3()


func _ready():
	set_fixed_process(true)


func _fixed_process(delta):
	if is_network_master():
		rset_unreliable("_target", _player.get_target())
		
	get_node("Head").look_at(_target, get_transform().basis.y)
	pass
