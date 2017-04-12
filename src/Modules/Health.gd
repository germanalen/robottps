extends Spatial


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
	var explosion = load("res://src/Modules/ExplosionParticles.tscn").instance()
	get_node("/root/Game/Other").add_child(explosion)
	var global_transform = explosion.get_global_transform()
	global_transform.origin = get_global_transform().origin
	explosion.set_global_transform(global_transform)
	explosion.set_emitting(true)
	
	_module.free()