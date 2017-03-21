extends Spatial



func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func get_configuration():
	var conf_dict = {
	name = get_name(), 
	x = get_translation().x,
	y = get_translation().y,
	z = get_translation().z}
	return conf_dict.to_json()

func parse_configuration(conf):
	var conf_dict = {}
	conf_dict.parse_json(conf)
	set_name(conf_dict.name)
	set_translation(Vector3(conf_dict.x, conf_dict.y, conf_dict.z))
	
	var bottom = TestCube.new()
	var top = TestCube.new()
	top.set_translation(Vector3(0, 2, 0))
	top.set_scale(Vector3(0.7, 0.7, 0.7))
	bottom.add_child(top)
	add_child(bottom)