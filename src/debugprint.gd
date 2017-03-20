extends Label


var lines = []
func debugprint(arg1=null, arg2=null, arg3=null, arg4=null, arg5=null, arg6=null, arg7=null, arg8=null, arg9=null):
	var line = ""
	line += str(arg1)
	line += str(arg2)
	line += str(arg3)
	line += str(arg4)
	line += str(arg5)
	line += str(arg6)
	line += str(arg7)
	line += str(arg8)
	line += str(arg9)
	
	if lines.size() >= 10:
		lines.pop_front()
	lines.push_back(line)
	
	var text = ""
	for line in lines:
		text += (line + "\n")
	set_text(text)