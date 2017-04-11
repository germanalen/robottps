extends Spatial

# This scene is for providing modules modules-attaching capability

var _player = null
func set_player(player):
	_player = player

func get_player():
	return _player

func attach_module(module):
	module.set_name(module.get_name() + str(get_child_count()))
	module.set_player(_player)
	add_child(module)


func get_configurations_array():
	var configurations = []
	
	for module in get_children():
		var tuple = [module.get_filename(), module.get_configuration()]
		configurations.append(tuple)
	
	return configurations


func parse_configurations_array(configurations):
	for tuple in configurations:
		var module = load(tuple[0]).instance()
		module.parse_configuration(tuple[1])
		attach_module(module)