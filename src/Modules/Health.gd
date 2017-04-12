extends Node


export var _max_health = 10
onready var _health = _max_health

export(NodePath) var _module_path
onready var _module = get_node(_module_path)


func deal_damage(damage):
	_health -= damage
	if _health <= 0:
		die_deferred()
		lobby.rrpc0(self, "die_deferred")


remote func die_deferred():
	call_deferred("die")

func die():
	# boom, sparks, flames
	_module.free()